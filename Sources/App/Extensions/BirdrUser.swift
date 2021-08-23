import Vapor
import BirdrUserModel

private enum Keys: String {
    case userName
    case feedKey
    case location
    case profilePhotoKey
    case description
    
    var vKey: ValidationKey { .string(rawValue) }
}

// This adds Vapor-specific deps to our user
extension BirdrUser: Content {}


// This allows us to run validation on a user
extension BirdrUser: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add(Keys.userName.vKey, as: String.self, is: .ascii, required: true)
        validations.add(Keys.feedKey.vKey, as: String.self, is: .ascii, required: false)
        validations.add(Keys.location.vKey, as: String.self, is: .ascii, required: false)
        validations.add(Keys.profilePhotoKey.vKey, as: String.self, is: .ascii, required: false)
        validations.add(Keys.description.vKey, as: String.self, is: .ascii, required: false)
    }
}

extension BirdrUser.Request: Content {}
extension BirdrUser.Return: Content {}
