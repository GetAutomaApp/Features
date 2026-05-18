import FeaturesShared
import Fluent
import Foundation

public struct FeatureService: Sendable {
    public let db: Database
    public let registry: FeatureRegistry

    public init(db: Database, registry: FeatureRegistry) {
        self.db = db
        self.registry = registry
    }

    public func resolve(subject: FeatureSubject) async throws -> [String: Bool] {
        let overrideRows = try await FeatureOverride.query(on: db)
            .filter(\.$subjectId == subject.id)
            .filter(\.$latest == true)
            .all()

        let overrideMap = Dictionary(uniqueKeysWithValues: overrideRows.map { ($0.featureKey, $0.enabled) })
        let context = FeatureContext(subject: subject, now: Date())

        var result: [String: Bool] = [:]
        for feature in registry.features {
            if let overridden = overrideMap[feature.key.rawValue] {
                result[feature.key.rawValue] = overridden
            } else {
                result[feature.key.rawValue] = feature.active(context)
            }
        }
        return result
    }

    public func debug(subject: FeatureSubject) async throws -> [FeatureDebugResultDTO] {
        let overrideRows = try await FeatureOverride.query(on: db)
            .filter(\.$subjectId == subject.id)
            .filter(\.$latest == true)
            .all()

        let overrideMap = Dictionary(uniqueKeysWithValues: overrideRows.map { ($0.featureKey, $0.enabled) })
        let context = FeatureContext(subject: subject, now: Date())

        return registry.features.map { feature in
            if let overridden = overrideMap[feature.key.rawValue] {
                return FeatureDebugResultDTO(key: feature.key.rawValue, enabled: overridden, source: "override")
            }
            return FeatureDebugResultDTO(key: feature.key.rawValue, enabled: feature.active(context), source: "code")
        }
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
