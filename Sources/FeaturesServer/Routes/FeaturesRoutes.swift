import FeaturesShared
import Vapor

struct FeatureToggleResponse: Content {
    let key: String
    let enabled: Bool
    let changedBy: String
    let source: String
}

enum FeaturesRoutes {
    static func register<Context: Sendable>(
        app: Application,
        config: FeaturesConfiguration,
        registry: FeatureRegistry<Context>,
        featureEvaluationMiddleware: FeatureEvaluationMiddleware<Context>
    ) {
        var authenticated: any RoutesBuilder = app
        for middleware in config.authMiddleware {
            authenticated = authenticated.grouped(middleware)
        }

        let group = authenticated
            .grouped(featureEvaluationMiddleware)
            .grouped(config.routePrefix)

        group.get(use: getFeatures)
        group.post("toggle", use: { req in
            try await toggleFeature(req: req, config: config, registry: registry)
        })
    }

    static func getFeatures(req: Request) async throws -> FeatureMapDTO {
        let sortedFeatures = req.features.keys.sorted().map { key in
            FeatureValueDTO(key: key, enabled: req.features[key] ?? false)
        }
        return .init(features: sortedFeatures)
    }

    static func toggleFeature<Context: Sendable>(
        req: Request,
        config: FeaturesConfiguration,
        registry: FeatureRegistry<Context>
    ) async throws -> FeatureToggleResponse {
        guard let routeContext = req.featureRouteContext(as: Context.self) else {
            throw Abort(.unauthorized)
        }

        let input = try req.content.decode(ClientFeatureToggleRequestDTO.self)

        guard let definition = registry.byKey(input.key) else {
            throw Abort(.notFound, reason: "Unknown feature key: \(input.key)")
        }

        guard definition.canToggleOnClient else {
            throw Abort(.forbidden, reason: "Feature cannot be toggled by client: \(input.key)")
        }

        let service = FeatureService(db: req.db(config.databaseID), registry: registry)
        try await service.applyOverride(
            subjectId: routeContext.subjectId,
            key: input.key,
            enabled: input.enabled,
            changedBy: routeContext.changedBy,
            channel: "client"
        )

        let nextMap = try await service.resolve(subjectId: routeContext.subjectId, context: routeContext.context)
        req.setFeatures(nextMap)

        return .init(key: input.key, enabled: input.enabled, changedBy: routeContext.changedBy, source: "client")
    }
}
