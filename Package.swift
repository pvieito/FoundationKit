// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "FoundationKit",
    products: [
        .library(name: "FoundationKit", targets: ["FoundationKit"]),
    ],
    targets: [
        .target(
            name: "FoundationKit",
            path: "FoundationKit"
        ),
        .testTarget(
            name: "FoundationKitTests",
            dependencies: ["FoundationKit"]
        ),
    ]
)
