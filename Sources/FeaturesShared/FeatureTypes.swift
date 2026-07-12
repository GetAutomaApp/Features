import Foundation

public struct FeatureKey: RawRepresentable, Hashable, Codable, Sendable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }
}

public struct FeatureValueDTO: Codable, Sendable {
    public let key: String
    public let enabled: Bool

    public init(key: String, enabled: Bool) {
        self.key = key
        self.enabled = enabled
    }
}

public struct FeatureMapDTO: Codable, Sendable {
    public let features: [FeatureValueDTO]

    public init(features: [FeatureValueDTO]) {
        self.features = features
    }
}

public struct ClientFeatureToggleRequestDTO: Codable, Sendable {
    public let key: String
    public let enabled: Bool

    public init(key: String, enabled: Bool) {
        self.key = key
        self.enabled = enabled
    }
}
