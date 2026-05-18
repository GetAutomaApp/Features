import FeaturesShared
import Foundation

public struct FeatureContext<Context: Sendable>: Sendable {
    public let subjectId: UUID
    public let context: Context
    public let now: Date

    public init(subjectId: UUID, context: Context, now: Date) {
        self.subjectId = subjectId
        self.context = context
        self.now = now
    }
}

public struct FeatureDefinition<Context: Sendable>: Sendable {
    public let key: FeatureKey
    public let canToggleOnClient: Bool
    public let active: @Sendable (FeatureContext<Context>) -> Bool

    public init(
        key: FeatureKey,
        canToggleOnClient: Bool = false,
        active: @escaping @Sendable (FeatureContext<Context>) -> Bool
    ) {
        self.key = key
        self.canToggleOnClient = canToggleOnClient
        self.active = active
    }
}

public struct FeatureRegistry<Context: Sendable>: Sendable {
    public let features: [FeatureDefinition<Context>]

    public init(features: [FeatureDefinition<Context>]) {
        self.features = features
    }

    public func byKey(_ key: String) -> FeatureDefinition<Context>? {
        features.first { $0.key.rawValue == key }
    }
}
