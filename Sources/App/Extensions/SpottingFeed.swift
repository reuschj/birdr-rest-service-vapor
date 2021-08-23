import Vapor
import BirdrModel

private enum Keys: String {
    case userKey
    
    var vKey: ValidationKey { .string(rawValue) }
}

// This adds Vapor-specific deps to our bird spotting feed
extension SpottingFeed: Content {}


// This allows us to run validation on a bird spotting feed
extension SpottingFeed: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add(Keys.userKey.vKey, as: String.self, is: .ascii, required: true)
    }
}

extension SpottingFeed.Post: Content {}
extension SpottingFeed.Request: Content {}
extension SpottingFeed.Return: Content {}
