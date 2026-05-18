import Fluent
import Foundation

public final class FeatureOverride: Model, @unchecked Sendable {
    public static let schema = "feature_overrides"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "subject_id")
    public var subjectId: UUID

    @Field(key: "feature_key")
    public var featureKey: String

    @Field(key: "enabled")
    public var enabled: Bool

    @Field(key: "latest")
    public var latest: Bool

    @Field(key: "changed_by")
    public var changedBy: String

    @Field(key: "channel")
    public var channel: String

    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?

    public init() {}

    public init(subjectId: UUID, featureKey: String, enabled: Bool, latest: Bool, changedBy: String, channel: String) {
        self.subjectId = subjectId
        self.featureKey = featureKey
        self.enabled = enabled
        self.latest = latest
        self.changedBy = changedBy
        self.channel = channel
    }
}
