// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "FeatureBreedsList",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "FeatureBreedsList",
            targets: ["FeatureBreedsList"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.10.0"),
        .package(path: "../CoreUI")
    ],
    targets: [
        .target(
            name: "FeatureBreedsList",
            dependencies: [
                "Swinject",
                "CoreUI"
            ]
        )
    ]
)
