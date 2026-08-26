// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DreamJotter",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .executable(
            name: "DreamJotterMac",
            targets: ["DreamJotterMac"]
        ),
        .library(
            name: "DreamJotterCore",
            targets: ["DreamJotterCore"]
        ),
        .library(
            name: "DreamJotteriOS",
            targets: ["DreamJotteriOS"]
        ),
        .library(
            name: "SpecSupport",
            targets: ["SpecSupport"]
        )
    ],
    targets: [
        .target(
            name: "DreamJotterCore"
        ),
        .target(
            name: "SpecSupport"
        ),
        .target(
            name: "DreamJotteriOS",
            dependencies: [
                "DreamJotterCore"
            ],
            path: "Apps/DreamJotteriOS"
        ),
        .executableTarget(
            name: "DreamJotterMac",
            dependencies: [
                "DreamJotterCore"
            ],
            path: "Apps/DreamJotterMac",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "DreamJotterExecutableSpecs",
            dependencies: [
                "DreamJotterCore",
                "SpecSupport"
            ],
            resources: [
                .process("Fixtures/Localization")
            ]
        ),
        .testTarget(
            name: "DreamJotteriOSTests",
            dependencies: [
                "DreamJotteriOS"
            ]
        ),
        .testTarget(
            name: "DreamJotterMacTests",
            dependencies: [
                "DreamJotterCore",
                "DreamJotterMac"
            ]
        )
    ]
)
