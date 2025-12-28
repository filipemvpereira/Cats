// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CoreResources",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "CoreResources",
            targets: ["CoreResources"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.10.0")
    ],
    targets: [
        .target(
            name: "CoreResources",
            dependencies: [
                "Swinject"
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
