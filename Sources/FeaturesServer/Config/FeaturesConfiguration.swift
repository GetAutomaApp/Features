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

public struct FeaturesRouteContext<Context: Sendable>: Sendable {
    public let subjectId: UUID
    public let context: Context
    public let changedBy: String

    public init(subjectId: UUID, context: Context, changedBy: String) {
        self.subjectId = subjectId
        self.context = context
        self.changedBy = changedBy
    }
}
