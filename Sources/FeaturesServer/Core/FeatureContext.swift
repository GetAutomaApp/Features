import FeaturesShared
import Foundation

public struct FeatureSubject: Sendable {
    public let id: UUID
    public let plan: String?
    public let isInternal: Bool
    public let attributes: [String: String]

    public init(id: UUID, plan: String? = nil, isInternal: Bool = false, attributes: [String: String] = [:]) {
        self.id = id
        self.plan = plan
        self.isInternal = isInternal
        self.attributes = attributes
    }
}

public struct FeatureContext: Sendable {
    public let subject: FeatureSubject
    public let now: Date

    public init(subject: FeatureSubject, now: Date) {
        self.subject = subject
        self.now = now
    }
}

public struct FeatureDefinition: Sendable {
    public let key: FeatureKey
    public let canToggleOnClient: Bool
    public let active: @Sendable (FeatureContext) -> Bool

    public init(
        key: FeatureKey,
        canToggleOnClient: Bool = false,
        active: @escaping @Sendable (FeatureContext) -> Bool
    ) {
        self.key = key
        self.canToggleOnClient = canToggleOnClient
        self.active = active
    }
}

public struct FeatureRegistry: Sendable {
    public let features: [FeatureDefinition]

    public init(features: [FeatureDefinition]) {
        self.features = features
    }

    public func byKey(_ key: String) -> FeatureDefinition? {
        features.first { $0.key.rawValue == key }
    }
}
