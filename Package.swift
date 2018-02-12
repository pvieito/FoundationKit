// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "FoundationKit",
    products: [
        .library(name: "FoundationKit", targets: ["FoundationKit"]),
    ],
    targets: [
        .target(name: "FoundationKit", path: "FoundationKit")
    ]
)
