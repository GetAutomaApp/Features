import Fluent

public struct CreateFeatureOverride: AsyncMigration {
    public init() {}

    public func prepare(on database: Database) async throws {
        try await database.schema("feature_overrides")
            .id()
            .field("subject_id", .uuid, .required)
            .field("feature_key", .string, .required)
            .field("enabled", .bool, .required)
            .field("latest", .bool, .required)
            .field("changed_by", .string, .required)
            .field("channel", .string, .required)
            .field("created_at", .datetime)
            .unique(on: "subject_id", "feature_key", "latest", name: "uq_feature_override_single_latest")
            .create()
    }

    public func revert(on database: Database) async throws {
        try await database.schema("feature_overrides").delete()
    }
}
