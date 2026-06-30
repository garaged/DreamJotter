// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DreamJotter",
    platforms: [
        .macOS(.v13)
    ],
    products: [
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
        .testTarget(
            name: "DreamJotterExecutableSpecs",
            dependencies: [
                "DreamJotterCore",
                "SpecSupport"
            ]
        )
    ]
)
