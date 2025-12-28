// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Network",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "Network",
            targets: ["Network"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.10.0")
    ],
    targets: [
        .target(
            name: "Network",
            dependencies: ["Swinject"]),
    ]
)
