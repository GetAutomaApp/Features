import Fluent
import Vapor

public struct FeaturesServerConfigurationStorage<Context: Sendable>: Sendable {
    let databaseID: DatabaseID?
    let registry: FeatureRegistry<Context>
}

private struct FeaturesServerConfigurationStorageKey: StorageKey {
    typealias Value = any Sendable
}

public extension Application {
    func featuresServerStorage<Context: Sendable>(as _: Context.Type = Context.self) -> FeaturesServerConfigurationStorage<Context>? {
        storage[FeaturesServerConfigurationStorageKey.self] as? FeaturesServerConfigurationStorage<Context>
    }

    func setFeaturesServerStorage<Context: Sendable>(_ value: FeaturesServerConfigurationStorage<Context>) {
        storage[FeaturesServerConfigurationStorageKey.self] = value
    }
}

public enum FeaturesServer {
    public static func configure<Context: Sendable>(
        on app: Application,
        config: FeaturesConfiguration,
        registry: FeatureRegistry<Context>,
        actorResolver: @escaping @Sendable (Request) async throws -> FeaturesRouteContext<Context>?
    ) {
        app.setFeaturesServerStorage(.init(databaseID: config.databaseID, registry: registry))
        app.migrations.add(CreateFeatureOverride())

        app.middleware.use(
            FeatureEvaluationMiddleware(
                registry: registry,
                databaseID: config.databaseID,
                actorResolver: actorResolver
            )
        )

        FeaturesRoutes.register(app: app, config: config, registry: registry)
    }
}
