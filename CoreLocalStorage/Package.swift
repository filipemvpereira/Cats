// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CoreLocalStorage",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "CoreLocalStorage",
            targets: ["CoreLocalStorage"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.10.0")
    ],
    targets: [
        .target(
            name: "CoreLocalStorage",
            dependencies: ["Swinject"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    ]
)
