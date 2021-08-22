import Vapor
import Store

// configures your application
public func configure(_ app: Application, withStore store: Store = Store.shared) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // register routes
    try routes(app, withStore: store)
}
