import Fluent
import Vapor

public struct FeaturesConfiguration: Sendable {
    public let databaseID: DatabaseID?
    public let authMiddleware: [Middleware]
    public let routePrefix: PathComponent

    public init(databaseID: DatabaseID? = nil, authMiddleware: [Middleware], routePrefix: PathComponent = "features") {
        self.databaseID = databaseID
        self.authMiddleware = authMiddleware
        self.routePrefix = routePrefix
    }
}

public struct FeaturesRouteActor: Sendable {
    public let subject: FeatureSubject
    public let changedBy: String

    public init(subject: FeatureSubject, changedBy: String) {
        self.subject = subject
        self.changedBy = changedBy
    }
}
