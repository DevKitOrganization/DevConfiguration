// swift-tools-version: 6.1

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny")
]

let package = Package(
    name: "DevConfiguration",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .tvOS(.v18),
        .visionOS(.v2),
        .watchOS(.v11),
    ],
    products: [
        .library(
            name: "DevConfiguration",
            targets: ["DevConfiguration"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/DevKitOrganization/DevTesting", from: "1.0.0-beta.7"),
    ],
    targets: [
        .target(
            name: "DevConfiguration",
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "DevConfigurationTests",
            dependencies: [
                "DevConfiguration",
                "DevTesting",
            ],
            swiftSettings: swiftSettings
        ),
    ]
)
