import FeaturesShared
import Vapor

struct FeatureToggleResponse: Content {
    let key: String
    let enabled: Bool
    let changedBy: String
    let source: String
}

enum FeaturesRoutes {
    static func register(
        app: Application,
        config: FeaturesConfiguration,
        registry: FeatureRegistry
    ) {
        let group = app.grouped(config.authMiddleware).grouped(config.routePrefix)

        group.get(use: getFeatures)
        group.get("debug", use: debugFeatures)
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

    static func debugFeatures(req: Request) async throws -> [FeatureDebugResultDTO] {
        guard let actor = req.featureActor else {
            throw Abort(.unauthorized)
        }

        let featuresServer = req.application.featuresServer
        let service = FeatureService(db: req.db(featuresServer.databaseID), registry: featuresServer.registry)
        return try await service.debug(subject: actor.subject)
    }

    static func toggleFeature(req: Request, config: FeaturesConfiguration, registry: FeatureRegistry) async throws -> FeatureToggleResponse {
        guard let actor = req.featureActor else {
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
            subjectId: actor.subject.id,
            key: input.key,
            enabled: input.enabled,
            changedBy: actor.changedBy,
            channel: "client"
        )

        let nextMap = try await service.resolve(subject: actor.subject)
        req.setFeatures(nextMap)

        return .init(key: input.key, enabled: input.enabled, changedBy: actor.changedBy, source: "client")
    }
}
