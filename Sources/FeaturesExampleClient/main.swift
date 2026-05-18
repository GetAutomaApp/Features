import FeaturesClient
import FeaturesShared
import Foundation

@main
struct FeaturesExampleClient {
    static func main() async throws {
        let server = URL(string: ProcessInfo.processInfo.environment["FEATURES_SERVER_URL"] ?? "http://127.0.0.1:8080")!
        let userID = ProcessInfo.processInfo.environment["FEATURES_USER_ID"] ?? "11111111-1111-1111-1111-111111111111"

        let client = FeaturesClient(baseURL: server) {
            "dev-token"
        }

        print("Using user: \(userID)")
        print("Set header x-user-id manually if testing with curl; this simple CLI only demonstrates SDK calls.")

        let features = try await client.getFeatures()
        print("Current features: \(features)")

        try await client.toggleFeature(key: FeatureKey(rawValue: "new_checkout"), enabled: true)
        let updated = try await client.getFeatures()
        print("After toggle: \(updated)")
    }
}
