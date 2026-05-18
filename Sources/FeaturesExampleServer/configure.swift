import FeaturesServer
import FeaturesShared
import Fluent
import FluentSQLiteDriver
import Vapor

func configure(_ app: Application) async throws {
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    app.migrations.add(CreateUser())

    let registry = FeatureRegistry(features: [
        .init(key: FeatureKey(rawValue: "new_checkout"), canToggleOnClient: true, active: { ctx in
            if ctx.subject.isInternal {
                return true
            }
            return FeatureBucketing.bucket(subjectId: ctx.subject.id, featureKey: FeatureKey(rawValue: "new_checkout")) < 30
        }),
        .init(key: FeatureKey(rawValue: "pro_feature"), canToggleOnClient: false, active: { ctx in
            ctx.subject.plan == "pro"
        }),
    ])

    let auth = MockAuthMiddleware()

    FeaturesServer.configure(
        on: app,
        config: .init(databaseID: .sqlite, authMiddleware: [auth], routePrefix: "features"),
        registry: registry,
        actorResolver: { req in
            guard let user = req.storage[MockAuthUserKey.self] else {
                return nil
            }

            return .init(
                subject: .init(
                    id: user.id,
                    plan: user.plan,
                    isInternal: user.isInternal,
                    attributes: ["name": user.name]
                ),
                changedBy: user.id.uuidString
            )
        }
    )

    try app.register(collection: GameController())

    try await app.autoMigrate()
    try await seedIfNeeded(app: app)
}

struct MockAuthedUser: Sendable {
    let id: UUID
    let name: String
    let plan: String
    let isInternal: Bool
}

struct MockAuthUserKey: StorageKey {
    typealias Value = MockAuthedUser
}

struct MockAuthMiddleware: AsyncMiddleware {
    func respond(to req: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let rawUserID = req.headers.first(name: "x-user-id")
            ?? req.headers.bearerAuthorization?.token

        guard let raw = rawUserID, let id = UUID(uuidString: raw) else {
            throw Abort(.unauthorized, reason: "Missing x-user-id header or bearer token containing user UUID")
        }

        guard let user = try await User.find(id, on: req.db(.sqlite)) else {
            throw Abort(.unauthorized, reason: "User not found")
        }

        req.storage[MockAuthUserKey.self] = .init(
            id: try user.requireID(),
            name: user.name,
            plan: user.plan,
            isInternal: user.isInternal
        )

        return try await next.respond(to: req)
    }
}

private func seedIfNeeded(app: Application) async throws {
    if try await User.query(on: app.db(.sqlite)).count() > 0 {
        return
    }

    try await User(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111"), name: "Alice", plan: "free", isInternal: false)
        .create(on: app.db(.sqlite))

    try await User(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222"), name: "Bob", plan: "pro", isInternal: false)
        .create(on: app.db(.sqlite))

    try await User(id: UUID(uuidString: "33333333-3333-3333-3333-333333333333"), name: "Carol", plan: "free", isInternal: true)
        .create(on: app.db(.sqlite))
}
