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
