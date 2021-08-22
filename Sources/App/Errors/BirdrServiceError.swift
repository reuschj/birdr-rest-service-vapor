import Foundation
import Vapor

enum BirdrServiceError: Error {
    case noImageDataSent
    case invalidImageType
    case imageKeyNotSpecified
    case imageNotFound(key: String)
    case entryNotFound(key: String)
    case validationsError(ValidationsError)
    case errorWhileDecodingBody(DecodingError)
    case otherError(Error)
}

extension BirdrServiceError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .imageKeyNotSpecified, .noImageDataSent, .invalidImageType:
            return .badRequest
        case .imageNotFound(key: _):
            return .notFound
        case .entryNotFound(key: _):
            return .notFound
        case .validationsError(_):
            return .badRequest
        case .errorWhileDecodingBody(_):
            return .badRequest
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
        case .imageKeyNotSpecified:
            return "No valid image key was specified."
        case .imageNotFound(key: let key):
            return "No image was found at the specified key: \(key)"
        case .entryNotFound(key: let key):
            return "No bird entry was found at the specified key: \(key)"
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
