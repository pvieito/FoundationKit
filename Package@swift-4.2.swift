// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "FoundationKit",
    products: [
        .library(name: "FoundationKit", targets: ["FoundationKit"]),
    ],
    targets: [
        .target(name: "FoundationKit", path: "FoundationKit")
    ],
    swiftLanguageVersions: [.v4, .v4_2]
)
