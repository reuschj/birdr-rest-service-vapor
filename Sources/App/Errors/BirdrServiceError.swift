import Foundation
import Vapor

enum BirdrServiceError: Error {
    case noImageDataSent
    case invalidImageType
    case keyNotSpecified(description: String?)
    case userIDNotSpecified
    case keyMismatch(keys: (String, String), reason: String)
    case imageNotFound(key: String)
    case spottingNotFound(key: String)
    case feedNotFound(key: String)
    case userNotFound(key: String)
    case validationsError(ValidationsError)
    case errorWhileDecodingBody(DecodingError)
    case otherError(Error)
}

extension BirdrServiceError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .userIDNotSpecified, .noImageDataSent, .invalidImageType:
            return .badRequest
        case .keyNotSpecified(description: _):
            return .badRequest
        case .imageNotFound(key: _):
            return .notFound
        case .spottingNotFound(key: _):
            return .notFound
        case .feedNotFound(key: _):
            return .notFound
        case .userNotFound(key: _):
            return .notFound
        case .validationsError(_):
            return .badRequest
        case .errorWhileDecodingBody(_):
            return .badRequest
        case .keyMismatch(_, _):
            return .internalServerError
        case .otherError(_):
            return .internalServerError
        }
    }
    var reason: String {
        switch self {
        case .noImageDataSent:
            return "No image data was sent"
        case .invalidImageType:
            return "The image type sent was not valid."
        case .keyNotSpecified(description: let description):
            return "No valid \(description.map { "\($0) " } ?? "")key was specified."
        case .userIDNotSpecified:
            return "No user ID was specified."
        case .keyMismatch(keys: let (key01, key02), reason: let reason):
            return "Keys did not match (\(key01) vs.\(key02)): \(reason)"
        case .imageNotFound(key: let key):
            return "No image was found at the specified key: \(key)"
        case .spottingNotFound(key: let key):
            return "No bird spotting was found at the specified key: \(key)"
        case .feedNotFound(key: let key):
            return "No bird spotting feed was found at the specified key: \(key)"
        case .userNotFound(key: let key):
            return "No user was found at the specified key: \(key)"
        case .validationsError(let validationsError):
            return validationsError.reason
        case .errorWhileDecodingBody(let decodingError):
            return decodingError.reason
        case .otherError(let error):
            return error.localizedDescription
        }
    }
    var missingBodyKey: String? {
        switch self {
        case .errorWhileDecodingBody(let decodingError):
            switch decodingError {
            case .keyNotFound(let codingKey, _):
                return codingKey.stringValue
            default:
                return nil
            }
        default:
            return nil
        }
    }
    var invalidType: Any.Type? {
        switch self {
        case .errorWhileDecodingBody(let decodingError):
            switch decodingError {
            case .typeMismatch(let type, _):
                return type
            default:
                return nil
            }
        default:
            return nil
        }
    }
}
