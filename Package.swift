// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "FoundationKit",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v5),
    ],
    products: [
        .library(
            name: "FoundationKit",
            targets: ["FoundationKit"]
        ),
        .library(
            name: "FoundationKitMac",
            targets: ["FoundationKitMac"]
        )
    ],
    targets: [
        .target(
            name: "FoundationKit",
            path: "FoundationKit"
        ),
        .target(
            name: "FoundationKitMac",
            path: "FoundationKitMac"
        ),
        .testTarget(
            name: "FoundationKitTests",
            dependencies: ["FoundationKit"]
        )
    ]
)
