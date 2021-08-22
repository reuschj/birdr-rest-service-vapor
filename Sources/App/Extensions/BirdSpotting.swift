import Vapor
import BirdrModel

private enum Keys: String {
    case title
    case imageKeys
    case description
    
    var vKey: ValidationKey { .string(rawValue) }
}

// This adds Vapor-specific deps to our bird spotting
extension BirdSpotting: Content {}


// This allows us to run validation on a bird spotting
extension BirdSpotting: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add(Keys.title.vKey, as: String.self, is: .ascii, required: true)
        validations.add(Keys.imageKeys.vKey, as: Set<String>.self, is: .valid, required: true)
        validations.add(Keys.description.vKey, as: String.self, is: .ascii, required: false)
    }
}

extension BirdSpotting.Request: Content {}
extension BirdSpotting.Return: Content {}
