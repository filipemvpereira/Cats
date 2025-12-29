// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "FeatureFavourites",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "FeatureFavourites",
            targets: ["FeatureFavourites"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.10.0"),
        .package(path: "../CoreUI"),
        .package(path: "../CoreBreeds"),
        .package(path: "../CoreResources")
    ],
    targets: [
        .target(
            name: "FeatureFavourites",
            dependencies: [
                "Swinject",
                "CoreUI",
                "CoreBreeds",
                "CoreResources"
            ]
        )
    ]
)
