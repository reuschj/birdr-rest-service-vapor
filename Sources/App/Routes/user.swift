import Vapor
import BirdrUserModel
import BirdrModel

// Route path constants -------- /
private let user: PathComponent = "user"
private let feed: PathComponent = "feed"
private let authentication: PathComponent = "authentication" // TODO Temp

// Param constants -------- /
private enum Param: String {
    case key
    case feedKey
    case spottingKey
    case userName // TODO Temp
    case password // TODO Temp
    
    var pc: PathComponent { ":\(rawValue)" }
}

let userRoutes: SetupFunction = { app, store in
    
    // POST User Create ----- /
    
    app.post(user) { req -> BirdrUser.Return in
        do {
            try BirdrUser.validate(content: req)
            let user = try req.content.decode(BirdrUser.Request.self).convert()
            let key = store.set(user, withKey: user.key)
            // TODO: Temp For reverse username lookup... Just temp for the dummy auth
            _ = store.set(user.key, withKey: user.userName)
            // TODO: End temp ----
            guard key == user.key else {
                throw BirdrServiceError.keyMismatch(
                    keys: (key, user.key),
                    reason: "Attempting to create a user with key \(user.key) at \(key)."
                )
            }
            return user.makeReturn(withDifferentKey: key)
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
    
    // POST User Auth -----
    
    // TODO: This is a dumb temporary auth
    // For now, this is just a dumb simulation of logging in
    // Just specify a username that exists and the password is "abcdefg"
    // This would be replaced for actual authentication.
    app.get(user, authentication, Param.userName.pc, Param.password.pc) { req -> BirdrUser in
        guard
            let userName = req.parameters.get(Param.userName.rawValue),
            let password = req.parameters.get(Param.password.rawValue) else {
            throw BirdrServiceError.userIDNotSpecified
        }
        guard password == "abcdefg" else { // Dumb hardcoded password for demo only
            throw Abort(.unauthorized, reason: "The password you entered is incorrect.")
        }
        guard let userKey: String = store.get(fromKey: userName) else {
            throw Abort(.notFound, reason: "The user name was not found.")
        }
        guard let user: BirdrUser = store.get(fromKey: userKey) else {
            throw BirdrServiceError.userNotFound(key: userKey)
        }
        return user
    }
    
    // POST User Link Feed ----- /
    
    app.post(user, Param.key.pc, feed, Param.feedKey.pc) { req -> BirdrUser in
        guard let key = req.parameters.get(Param.key.rawValue) else {
            throw BirdrServiceError.keyNotSpecified(description: "user")
        }
        guard var user: BirdrUser = store.get(fromKey: key) else {
            throw BirdrServiceError.userNotFound(key: key)
        }
        guard let feedKey = req.parameters.get(Param.feedKey.rawValue) else {
            throw BirdrServiceError.keyNotSpecified(description: "feed")
        }
        guard var feed: SpottingFeed<BirdSpotting> = store.get(fromKey: feedKey) else {
            throw BirdrServiceError.feedNotFound(key: key)
        }
        // Exchange keys
        user.feedKey = feed.key
        feed.userKey = user.key
        // Store mutated results
        let userSetKey = store.set(user, withKey: user.key)
        let feedSetKey = store.set(feed, withKey: feed.key)
        let makeMismatchError: (String, String, String) -> BirdrServiceError = { key01, key02, description in
            BirdrServiceError.keyMismatch(
                keys: (key01, key02),
                reason: "Attempting to \(description) with key \(key01) at \(key02)."
            )
        }
        guard userSetKey == key else {
            throw makeMismatchError(userSetKey, key, "set updated user")
        }
        guard userSetKey == user.key else {
            throw makeMismatchError(userSetKey, user.key, "set updated user")
        }
        guard feedSetKey == feedKey else {
            throw makeMismatchError(feedSetKey, feedKey, "set updated feed")
        }
        guard feedSetKey == feed.key else {
            throw makeMismatchError(feedSetKey, feed.key, "set updated feed")
        }
        return user
    }
    
    // GET User Read ----- /
    
    app.get(user, Param.key.pc) { req -> BirdrUser in
        guard let key = req.parameters.get(Param.key.rawValue) else {
            throw BirdrServiceError.keyNotSpecified(description: "user")
        }
        guard let user: BirdrUser = store.get(fromKey: key) else {
            throw BirdrServiceError.userNotFound(key: key)
        }
        return user
    }
}

