// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Scout",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "Scout",
            targets: ["Scout"]
        ),
        .library(
            name: "ScoutCache",
            targets: ["ScoutCache"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-metrics.git", "1.0.0"..<"3.0.0"),
        .package(url: "https://github.com/kasianov-mikhail/scout-db.git", from: "0.10.0"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin.git", from: "1.4.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.18.0"),
    ],
    targets: [
        .target(
            name: "ScoutHang"
        ),
        .target(
            name: "Scout",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Metrics", package: "swift-metrics"),
                .product(name: "ScoutDB", package: "scout-db"),
                "ScoutHang",
            ],
            resources: [
                .process("Core/Persistence/ScoutModel.xcdatamodeld")
            ]
        ),
        .target(
            name: "ScoutCache",
            dependencies: [
                "Scout"
            ]
        ),
        .testTarget(
            name: "ScoutTests",
            dependencies: [
                "Scout",
                .product(name: "ScoutDBTesting", package: "scout-db"),
            ]
        ),
        .testTarget(
            name: "ScoutSnapshotTests",
            dependencies: [
                "Scout",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
        .testTarget(
            name: "ScoutCacheTests",
            dependencies: [
                "ScoutCache",
                "Scout",
            ]
        ),
    ]
)
