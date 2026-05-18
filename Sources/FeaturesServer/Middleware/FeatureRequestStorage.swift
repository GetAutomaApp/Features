import FeaturesShared
import Vapor

private struct FeatureStorageKey: StorageKey {
    typealias Value = [String: Bool]
}

private struct FeatureActorStorageKey: StorageKey {
    typealias Value = FeaturesRouteActor
}

public extension Request {
    var features: [String: Bool] {
        storage[FeatureStorageKey.self] ?? [:]
    }

    func feature(_ key: FeatureKey) -> Bool {
        features[key.rawValue] ?? false
    }

    var featureActor: FeaturesRouteActor? {
        storage[FeatureActorStorageKey.self]
    }

    func setFeatures(_ value: [String: Bool]) {
        storage[FeatureStorageKey.self] = value
    }

    func setFeatureActor(_ value: FeaturesRouteActor) {
        storage[FeatureActorStorageKey.self] = value
    }
}
