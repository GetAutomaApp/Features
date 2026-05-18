import Fluent
import Vapor

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "plan")
    var plan: String

    @Field(key: "is_internal")
    var isInternal: Bool

    init() {}

    init(id: UUID? = nil, name: String, plan: String, isInternal: Bool) {
        self.id = id
        self.name = name
        self.plan = plan
        self.isInternal = isInternal
    }
}
