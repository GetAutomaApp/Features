import Fluent
import Vapor

public struct FeaturesServerConfigurationStorage: Sendable {
    let databaseID: DatabaseID?
    let registry: FeatureRegistry
}

private struct FeaturesServerConfigurationStorageKey: StorageKey {
    typealias Value = FeaturesServerConfigurationStorage
}

public extension Application {
    var featuresServer: FeaturesServerConfigurationStorage {
        get {
            guard let storage = self.storage[FeaturesServerConfigurationStorageKey.self] else {
                fatalError("FeaturesServer not configured. Call FeaturesServer.configure first.")
            }
            return storage
        }
        set {
            self.storage[FeaturesServerConfigurationStorageKey.self] = newValue
        }
    }
}

public enum FeaturesServer {
    public static func configure(
        on app: Application,
        config: FeaturesConfiguration,
        registry: FeatureRegistry,
        actorResolver: @escaping @Sendable (Request) async throws -> FeaturesRouteActor?
    ) {
        app.featuresServer = .init(databaseID: config.databaseID, registry: registry)
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
