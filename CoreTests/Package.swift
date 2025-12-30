// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CoreTests",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "CoreTests",
            targets: ["CoreTests"]
        ),
    ],
    dependencies: [
        .package(path: "../Network"),
        .package(path: "../CoreLocalStorage")
    ],
    targets: [
        .target(
            name: "CoreTests",
            dependencies: [
                "Network",
                "CoreLocalStorage"
            ]
        )
    ]
)
