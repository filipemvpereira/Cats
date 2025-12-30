// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "FeatureBreedDetail",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "FeatureBreedDetail",
            targets: ["FeatureBreedDetail"]
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
            name: "FeatureBreedDetail",
            dependencies: [
                "Swinject",
                "CoreUI",
                "CoreBreeds",
                "CoreResources"
            ]
        ),
        .testTarget(
            name: "FeatureBreedDetailTests",
            dependencies: ["FeatureBreedDetail", "CoreBreeds", "CoreResources"]
        )
    ]
)
