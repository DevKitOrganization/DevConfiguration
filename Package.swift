// swift-tools-version: 6.2

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("MemberImportVisibility"),
]

let package = Package(
    name: "DevConfiguration",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .tvOS(.v26),
        .visionOS(.v26),
        .watchOS(.v26),
    ],
    products: [
        .library(
            name: "DevConfiguration",
            targets: ["DevConfiguration"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/DevKitOrganization/DevFoundation.git", from: "1.7.0"),
        .package(url: "https://github.com/DevKitOrganization/DevTesting", from: "1.5.0"),
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
