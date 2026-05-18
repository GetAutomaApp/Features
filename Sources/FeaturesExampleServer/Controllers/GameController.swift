import FeaturesShared
import FeaturesServer
import Vapor

struct GameStateDTO: Content {
    let message: String
    let newCheckoutEnabled: Bool
    let proFeatureEnabled: Bool
}

struct GameController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get("game") { req async throws -> GameStateDTO in
            let canSeeCastle = req.feature(FeatureKey(rawValue: "new_checkout"))
            let hasProSword = req.feature(FeatureKey(rawValue: "pro_feature"))

            let message: String
            if canSeeCastle {
                message = "You unlocked the castle path."
            } else {
                message = "You are still in the village tutorial."
            }

            return .init(
                message: message,
                newCheckoutEnabled: canSeeCastle,
                proFeatureEnabled: hasProSword
            )
        }
    }
}
