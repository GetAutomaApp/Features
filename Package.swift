// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Features",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: "FeaturesShared", targets: ["FeaturesShared"]),
        .library(name: "FeaturesServer", targets: ["FeaturesServer"]),
        .library(name: "FeaturesClient", targets: ["FeaturesClient"]),
        .library(name: "FeaturesAdmin", targets: ["FeaturesAdmin"]),
        .executable(name: "FeaturesExampleServer", targets: ["FeaturesExampleServer"]),
        .executable(name: "FeaturesExampleClient", targets: ["FeaturesExampleClient"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.100.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.7.0")
    ],
    targets: [
        .target(name: "FeaturesShared"),
        .target(
            name: "FeaturesServer",
            dependencies: [
                "FeaturesShared",
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent")
            ]
        ),
        .target(name: "FeaturesClient", dependencies: ["FeaturesShared"]),
        .target(name: "FeaturesAdmin", dependencies: []),
        .executableTarget(
            name: "FeaturesExampleServer",
            dependencies: [
                "FeaturesServer",
                "FeaturesShared",
                "FeaturesClient",
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver")
            ]
        ),
        .executableTarget(name: "FeaturesExampleClient", dependencies: ["FeaturesClient", "FeaturesShared"])
    ]
)
