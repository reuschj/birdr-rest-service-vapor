// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "birdrService",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(
            url: "https://github.com/vapor/vapor.git",
            from: "4.0.0"
        ),
        .package(
            name: "BirdrFoundation",
            url: "https://github.com/reuschj/birdr-foundation-swift.git",
            from: "0.0.15"
        )
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "BirdrModel", package: "BirdrFoundation"),
                .product(name: "BirdrServiceModel", package: "BirdrFoundation"),
                .product(name: "BirdrUserModel", package: "BirdrFoundation"),
                .target(name: "Store")
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides/blob/main/docs/building.md#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Store", dependencies: []),
        .target(name: "Run", dependencies: [.target(name: "App"), .target(name: "Store")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor")
        ])
    ]
)
