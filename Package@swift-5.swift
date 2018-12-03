// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "FoundationKit",
    platforms: [
        .macOS(.v10_11)
    ],
    products: [
        .library(name: "FoundationKit", targets: ["FoundationKit"]),
    ],
    targets: [
        .target(name: "FoundationKit", path: "FoundationKit")
    ]
)
