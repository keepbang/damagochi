// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Damagochi",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "DamagochiApp", targets: ["DamagochiApp"]),
        .executable(name: "damagochi", targets: ["DamagochiCLI"]),
        .executable(name: "damagochi-sprite-catalog", targets: ["DamagochiSpriteCatalog"]),
        .library(name: "DamagochiCore", targets: ["DamagochiCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "DamagochiApp",
            dependencies: [
                "DamagochiCore",
                "DamagochiMonitor",
                "DamagochiStorage",
                "DamagochiRenderer",
                "DamagochiNetwork",
            ],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist", "-Xlinker", "Resources/Info.plist"]),
            ]
        ),
        .target(
            name: "DamagochiCore",
            dependencies: []
        ),
        .target(
            name: "DamagochiMonitor",
            dependencies: ["DamagochiCore"]
        ),
        .target(
            name: "DamagochiStorage",
            dependencies: ["DamagochiCore"]
        ),
        .target(
            name: "DamagochiRenderer",
            dependencies: ["DamagochiCore"]
        ),
        .target(
            name: "DamagochiNetwork",
            dependencies: ["DamagochiCore"]
        ),
        .executableTarget(
            name: "DamagochiCLI",
            dependencies: [
                "DamagochiCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .executableTarget(
            name: "DamagochiSpriteCatalog",
            dependencies: ["DamagochiCore", "DamagochiRenderer"]
        ),
        .testTarget(
            name: "DamagochiCoreTests",
            dependencies: ["DamagochiCore", "DamagochiMonitor", "DamagochiRenderer"]
        ),
        .testTarget(
            name: "DamagochiMonitorTests",
            dependencies: ["DamagochiMonitor"]
        ),
        .testTarget(
            name: "DamagochiIntegrationTests",
            dependencies: ["DamagochiCore"]
        ),
    ]
)
