import FeaturesShared
import Vapor

public struct RequireFeatureMiddleware: AsyncMiddleware {
    public let key: FeatureKey

    public init(key: FeatureKey) {
        self.key = key
    }

    public func respond(to req: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard req.feature(key) else {
            throw Abort(.forbidden, reason: "Feature not enabled: \(key.rawValue)")
        }
        return try await next.respond(to: req)
    }
}
