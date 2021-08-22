import Vapor
import BirdrModel

// Route path constants -------- /
private let spotting: PathComponent = "spotting"

// Param constants -------- /
private enum Param: String {
    case key
    
    var pc: PathComponent { ":\(rawValue)" }
}

let spottingRoutes: SetupFunction = { app, store in
    
    // POST Spotting Create ----- /
    
    app.post(spotting) { req -> BirdSpotting.Return in
        do {
            try BirdSpotting.validate(content: req)
            let birdSpotting = try req.content.decode(BirdSpotting.Request.self).convert()
            let key = store.set(birdSpotting, withKey: birdSpotting.key)
            guard key == birdSpotting.key else {
                throw BirdrServiceError.keyMismatch(
                    keys: (key, birdSpotting.key),
                    reason: "Attempting to set a spotting with key \(birdSpotting.key) at \(key)."
                )
            }
            return birdSpotting.makeReturn(withDifferentKey: key)
        } catch let serviceError as BirdrServiceError {
            throw serviceError
        } catch let validationsError as ValidationsError {
            throw BirdrServiceError.validationsError(validationsError)
        } catch let decodingError as DecodingError {
            throw BirdrServiceError.errorWhileDecodingBody(decodingError)
        } catch {
            throw BirdrServiceError.otherError(error)
        }
    }
    
    // GET Spotting Read ----- /
    
    app.get(spotting, Param.key.pc) { req -> BirdSpotting in
        guard let key = req.parameters.get(Param.key.rawValue) else {
            throw BirdrServiceError.keyNotSpecified(description: "spotting")
        }
        guard let birdSpotting: BirdSpotting = store.get(fromKey: key) else {
            throw BirdrServiceError.spottingNotFound(key: key)
        }
        return birdSpotting
    }
}
