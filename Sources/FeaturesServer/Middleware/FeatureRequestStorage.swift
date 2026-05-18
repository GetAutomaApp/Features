import FeaturesShared
import Vapor

private struct FeatureStorageKey: StorageKey {
    typealias Value = [String: Bool]
}

private struct FeatureRouteContextStorageKey: StorageKey {
    typealias Value = any Sendable
}

public extension Request {
    var features: [String: Bool] {
        storage[FeatureStorageKey.self] ?? [:]
    }

    func feature(_ key: FeatureKey) -> Bool {
        features[key.rawValue] ?? false
    }

    func featureRouteContext<Context: Sendable>(as _: Context.Type = Context.self) -> FeaturesRouteContext<Context>? {
        storage[FeatureRouteContextStorageKey.self] as? FeaturesRouteContext<Context>
    }

    func setFeatures(_ value: [String: Bool]) {
        storage[FeatureStorageKey.self] = value
    }

    func setFeatureRouteContext<Context: Sendable>(_ value: FeaturesRouteContext<Context>) {
        storage[FeatureRouteContextStorageKey.self] = value
    }
}
