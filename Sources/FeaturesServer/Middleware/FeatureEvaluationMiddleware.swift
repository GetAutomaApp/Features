import Fluent
import Vapor

public struct FeatureEvaluationMiddleware: AsyncMiddleware {
    private let registry: FeatureRegistry
    private let databaseID: DatabaseID?
    private let actorResolver: @Sendable (Request) async throws -> FeaturesRouteActor?

    public init(
        registry: FeatureRegistry,
        databaseID: DatabaseID?,
        actorResolver: @escaping @Sendable (Request) async throws -> FeaturesRouteActor?
    ) {
        self.registry = registry
        self.databaseID = databaseID
        self.actorResolver = actorResolver
    }

    public func respond(to req: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let actor = try await actorResolver(req) else {
            return try await next.respond(to: req)
        }

        req.setFeatureActor(actor)
        let service = FeatureService(db: req.db(databaseID), registry: registry)
        let resolved = try await service.resolve(subject: actor.subject)
        req.setFeatures(resolved)

        return try await next.respond(to: req)
    }
}
