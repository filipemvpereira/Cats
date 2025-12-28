// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CoreBreeds",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "CoreBreeds",
            targets: ["CoreBreeds"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.10.0"),
        .package(path: "../Network")
    ],
    targets: [
        .target(
            name: "CoreBreeds",
            dependencies: [
                "Swinject",
                "Network"
            ]
        )
    ]
)
