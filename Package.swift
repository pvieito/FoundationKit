// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "FoundationKit",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v9),
        .tvOS(.v9),
        .watchOS(.v2),
    ],
    products: [
        .library(
            name: "FoundationKit",
            targets: ["FoundationKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "1.1.4")
    ],
    targets: [
        .target(
            name: "FoundationKit",
            path: "FoundationKit"
        ),
        .testTarget(
            name: "FoundationKitTests",
            dependencies: ["FoundationKit"]
        )
    ]
)
