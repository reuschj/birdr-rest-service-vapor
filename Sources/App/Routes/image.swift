import Vapor
import BirdrServiceModel

// Route path constants -------- /
private let image: PathComponent = "image"

// Param constants -------- /
private enum Param: String {
    case name
    case key

    var pc: PathComponent { ":\(rawValue)" }
}

private let maxSize: ByteCount = "5mb"

let imageRoutes: SetupFunction = { app, store in
    
    /// Shared image setter logic
    let setImage: (Request) throws -> ImageStore.Return = { req in
        let name = req.parameters.get(Param.name.rawValue)
        guard let data = req.body.data else {
            throw BirdrServiceError.noImageDataSent
        }
        guard let type = req.headers.contentType else {
            throw BirdrServiceError.invalidImageType
        }
        let imageStore = ImageStore(data: Data(buffer: data), httpMediaType: type, withName: name)
        let key = store.set(imageStore, withKey: imageStore.key)
        guard key == imageStore.key else {
            throw BirdrServiceError.keyMismatch(
                keys: (key, imageStore.key),
                reason: "Attempting to set image with key \(imageStore.key) at \(key)."
            )
        }
        return imageStore.makeReturn(withDifferentKey: key)
    }

    /// Shared image getter logic
    let getImage: (Request) throws -> ImageStore = { req in
        guard let key = req.parameters.get(Param.key.rawValue) else {
            throw BirdrServiceError.keyNotSpecified(description: "image")
        }
        guard let imageStore: ImageStore = store.get(fromKey: key) else {
            throw BirdrServiceError.imageNotFound(key: key)
        }
        return imageStore
    }

    // PUT Image Create ----- /

    // with name
    app.on(.PUT, image, Param.name.pc, body: .collect(maxSize: maxSize), use: setImage)

    // without name
    app.on(.PUT, image, body: .collect(maxSize: maxSize), use: setImage)

    // GET Image Read ----- /

    app.get(image, Param.key.pc, use: getImage)
}
