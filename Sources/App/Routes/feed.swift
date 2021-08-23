import Vapor
import BirdrModel

// Route path constants -------- /
private let feed: PathComponent = "feed"
private let create: PathComponent = "create"
private let post: PathComponent = "post"

// Param constants -------- /
private enum Param: String {
    case key
    case userKey
    case spottingKey
    
    var pc: PathComponent { ":\(rawValue)" }
}

let feedRoutes: SetupFunction = { app, store in
    
    let setFeed: (SpottingFeed<BirdSpotting>) throws -> SpottingFeed<BirdSpotting>.Return = { feed in
        let key = store.set(feed, withKey: feed.key)
        guard key == feed.key else {
            throw BirdrServiceError.keyMismatch(
                keys: (key, feed.key),
                reason: "Attempting to set a feed with key \(feed.key) at \(key)."
            )
        }
        return feed.makeReturn(withDifferentKey: key)
    }
    
    // POST Feed Create ----- /
    
    app.post(feed, create) { req -> SpottingFeed<BirdSpotting>.Return in
        do {
            try SpottingFeed<BirdSpotting>.validate(content: req)
            let feed = try req.content.decode(SpottingFeed<BirdSpotting>.Request.self).convert()
            return try setFeed(feed)
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
    
    // PUT Feed Create ----- /
    
    app.put(feed, create, Param.userKey.pc) { req -> SpottingFeed<BirdSpotting>.Return in
        do {
            guard let userKey = req.parameters.get(Param.userKey.rawValue) else {
                throw BirdrServiceError.userIDNotSpecified
            }
            let feed: SpottingFeed<BirdSpotting> = .init(userKey: userKey)
            return try setFeed(feed)
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
    
    // PUT Feed Post ----- /
    
    app.put(feed, Param.key.pc, post, Param.spottingKey.pc) { req -> SpottingFeed<BirdSpotting>.Return in
        do {
            guard let key = req.parameters.get(Param.key.rawValue) else {
                throw BirdrServiceError.keyNotSpecified(description: "feed")
            }
            guard var feed: SpottingFeed<BirdSpotting> = store.get(fromKey: key) else {
                throw BirdrServiceError.feedNotFound(key: key)
            }
            guard let spottingKey = req.parameters.get(Param.spottingKey.rawValue) else {
                throw BirdrServiceError.keyNotSpecified(description: "spotting")
            }
            guard let birdSpotting: BirdSpotting = store.get(fromKey: spottingKey) else {
                throw BirdrServiceError.spottingNotFound(key: key)
            }
            feed.post(spotting: birdSpotting)
            let keySet = store.set(feed, withKey: feed.key)
            let makeMismatchError: (String, String) -> BirdrServiceError = { key01, key02 in
                BirdrServiceError.keyMismatch(
                    keys: (key01, key02),
                    reason: "Attempting to set a feed with key \(key01) at \(key02)."
                )
            }
            guard keySet == key else {
                throw makeMismatchError(keySet, key)
            }
            guard keySet == feed.key else {
                throw makeMismatchError(keySet, key)
            }
            return feed.makeReturn(withDifferentKey: key)
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
    
    // GET Feed Create ----- /
    
    app.get(feed, Param.key.pc) { req -> SpottingFeed<BirdSpotting> in
        guard let key = req.parameters.get(Param.key.rawValue) else {
            throw BirdrServiceError.keyNotSpecified(description: "feed")
        }
        guard let feed: SpottingFeed<BirdSpotting> = store.get(fromKey: key) else {
            throw BirdrServiceError.feedNotFound(key: key)
        }
        return feed
    }
}
