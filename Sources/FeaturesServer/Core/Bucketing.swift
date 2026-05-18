import CryptoKit
import FeaturesShared
import Foundation

public enum FeatureBucketing {
    public static func bucket(subjectId: UUID, featureKey: FeatureKey) -> Int {
        let input = "\(subjectId.uuidString):\(featureKey.rawValue)"
        let hash = SHA256.hash(data: Data(input.utf8))
        let value = hash.prefix(4).reduce(UInt32(0)) { partial, byte in
            (partial << 8) | UInt32(byte)
        }
        return Int(value % 100)
    }
}
