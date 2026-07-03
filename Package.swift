// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DreamJotter",
    platforms: [
        .macOS(.v14)
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
        .executableTarget(
            name: "DreamJotterMac",
            dependencies: [
                "DreamJotterCore"
            ],
            path: "Apps/DreamJotterMac"
        ),
        .testTarget(
            name: "DreamJotterExecutableSpecs",
            dependencies: [
                "DreamJotterCore",
                "SpecSupport"
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
