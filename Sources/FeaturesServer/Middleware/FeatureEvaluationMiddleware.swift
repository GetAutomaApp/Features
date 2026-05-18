import Fluent
import Vapor

public struct FeatureEvaluationMiddleware<Context: Sendable>: AsyncMiddleware {
    private let registry: FeatureRegistry<Context>
    private let databaseID: DatabaseID?
    private let actorResolver: @Sendable (Request) async throws -> FeaturesRouteContext<Context>?

    public init(
        registry: FeatureRegistry<Context>,
        databaseID: DatabaseID?,
        actorResolver: @escaping @Sendable (Request) async throws -> FeaturesRouteContext<Context>?
    ) {
        self.registry = registry
        self.databaseID = databaseID
        self.actorResolver = actorResolver
    }

    public func respond(to req: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let routeContext = try await actorResolver(req) else {
            return try await next.respond(to: req)
        }

        req.setFeatureRouteContext(routeContext)
        let service = FeatureService(db: req.db(databaseID), registry: registry)
        let resolved = try await service.resolve(subjectId: routeContext.subjectId, context: routeContext.context)
        req.setFeatures(resolved)

        return try await next.respond(to: req)
    }
}
