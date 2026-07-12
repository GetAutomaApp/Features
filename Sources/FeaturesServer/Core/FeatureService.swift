import FeaturesShared
import Fluent
import Foundation

public struct FeatureService<Context: Sendable>: Sendable {
    public let db: Database
    public let registry: FeatureRegistry<Context>

    public init(db: Database, registry: FeatureRegistry<Context>) {
        self.db = db
        self.registry = registry
    }

    public func resolve(subjectId: UUID, context: Context) async throws -> [String: Bool] {
        let overrideRows = try await FeatureOverride.query(on: db)
            .filter(\.$subjectId == subjectId)
            .filter(\.$latest == true)
            .all()

        let overrideMap = Dictionary(uniqueKeysWithValues: overrideRows.map { ($0.featureKey, $0.enabled) })
        let featureContext = FeatureContext(subjectId: subjectId, context: context, now: Date())

        var result: [String: Bool] = [:]
        for feature in registry.features {
            if let overridden = overrideMap[feature.key.rawValue] {
                result[feature.key.rawValue] = overridden
            } else {
                result[feature.key.rawValue] = feature.active(featureContext)
            }
        }
        return result
    }

    public func applyOverride(
        subjectId: UUID,
        key: String,
        enabled: Bool,
        changedBy: String,
        channel: String
    ) async throws {
        try await FeatureOverride.query(on: db)
            .filter(\.$subjectId == subjectId)
            .filter(\.$featureKey == key)
            .filter(\.$latest == true)
            .set(\.$latest, to: false)
            .update()

        let newRow = FeatureOverride(
            subjectId: subjectId,
            featureKey: key,
            enabled: enabled,
            latest: true,
            changedBy: changedBy,
            channel: channel
        )
        try await newRow.create(on: db)
    }
}
