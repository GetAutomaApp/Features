import FeaturesShared
import Foundation

public struct FeaturesClient: Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let authTokenProvider: @Sendable () async throws -> String

    public init(
        baseURL: URL,
        session: URLSession = .shared,
        authTokenProvider: @escaping @Sendable () async throws -> String
    ) {
        self.baseURL = baseURL
        self.session = session
        self.authTokenProvider = authTokenProvider
    }

    public func getFeatures() async throws -> [String: Bool] {
        var request = URLRequest(url: baseURL.appending(path: "features"))
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(try await authTokenProvider(), forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        try ensureSuccess(response: response, data: data)

        let decoded = try JSONDecoder().decode(FeatureMapDTO.self, from: data)
        return Dictionary(uniqueKeysWithValues: decoded.features.map { ($0.key, $0.enabled) })
    }

    public func toggleFeature(key: FeatureKey, enabled: Bool) async throws {
        var request = URLRequest(url: baseURL.appending(path: "features/toggle"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(try await authTokenProvider(), forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(ClientFeatureToggleRequestDTO(key: key.rawValue, enabled: enabled))

        let (data, response) = try await session.data(for: request)
        try ensureSuccess(response: response, data: data)
    }

    private func ensureSuccess(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "unknown error"
            throw FeaturesClientError.requestFailed(body)
        }
    }
}

public enum FeaturesClientError: Error {
    case requestFailed(String)
}
