import BirdrServiceModel
import Vapor

private enum Keys: String {
    case name
    case data
    case imageName
    
    var vKey: ValidationKey { .string(rawValue) }
}

extension HTTPMediaType {
    var imageType: ImageType? {
        ImageType(rawValue: self.description)
    }
}

// This adds Vapor-specific deps to our image store
extension ImageStore: Content {
    public var httpMediaType: HTTPMediaType {
        let split = type.rawValue.split(separator: "/")
        guard split.count == 2 else { return .any }
        return HTTPMediaType(type: String(split[0]), subType: String(split[1]))
    }

    public init?(
        data: Data,
        httpMediaType: HTTPMediaType? = nil,
        withName name: String? = nil
    ) {
        if let imageType = httpMediaType?.imageType {
            self.init(data: data, type: imageType, withName: name)
        } else {
            self.init(data: data, withName: name)
        }
    }
}

// This allows us to run validation on an image store
extension ImageStore: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add(Keys.name.vKey, as: String.self, is: .ascii, required: false)
        validations.add(Keys.data.vKey, as: Data.self, is: .valid, required: true)
    }
}

// This customizes how the image store is sent the service return
// In this case, we encode the content type into the headers and pass the data to the body
extension ImageStore: ResponseEncodable {
    public func encodeResponse(for request: Vapor.Request) -> EventLoopFuture<Response> {
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: self.type.rawValue)
        headers.add(name: .contentID, value: self.key)
        if let name = self.name {
            headers.add(name: Keys.imageName.rawValue, value: name)
        }
        return request.eventLoop.makeSucceededFuture(.init(
            status: .ok, headers: headers, body: .init(data: self.data)
        ))
    }
}

extension ImageStore.Return: Content {}
