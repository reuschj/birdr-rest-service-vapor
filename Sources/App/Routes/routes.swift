import Vapor
import Store

// A closure that sets up routes
typealias SetupFunction = (Application, Store) throws -> Void

// Batches route setup
func setupRoutes(
    for app: Application,
    withStore store: Store = Store.shared,
    with setupFunctions: [SetupFunction]
) throws {
    try setupFunctions.forEach { setupRoutes in
        try setupRoutes(app, store)
    }
}

// Setup all routes
func routes(_ app: Application, withStore store: Store = Store.shared) throws {
    try setupRoutes(for: app, withStore: store, with: [
        imageRoutes
    ])
}
