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
            name: "ScoutCore",
            targets: ["ScoutCore"]
        ),
        .library(
            name: "ConnectorNative",
            targets: ["ConnectorNative"]
        ),
        .library(
            name: "ConnectorHosted",
            targets: ["ConnectorHosted"]
        ),
        .library(
            name: "ScoutUI",
            targets: ["ScoutUI"]
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
            name: "ScoutCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Metrics", package: "swift-metrics"),
                "ScoutHang",
            ],
            resources: [
                .process("Persistence/ScoutModel.xcdatamodeld")
            ]
        ),
        .target(
            name: "ConnectorNative",
            dependencies: [
                "ScoutCore",
                .product(name: "ScoutDB", package: "scout-db"),
            ]
        ),
        .target(
            name: "ConnectorHosted",
            dependencies: [
                "ScoutCore"
            ]
        ),
        .target(
            name: "ScoutUI",
            dependencies: [
                "ScoutCore"
            ]
        ),
        .target(
            name: "ScoutCache",
            dependencies: [
                "ScoutCore"
            ]
        ),
        .target(
            name: "Scout",
            dependencies: [
                "ScoutCore",
                "ConnectorNative",
                "ConnectorHosted",
                "ScoutUI",
            ]
        ),
        .target(
            name: "ScoutTestSupport",
            dependencies: [
                "ScoutCore"
            ],
            path: "Tests/ScoutTestSupport"
        ),
        .testTarget(
            name: "ScoutCoreTests",
            dependencies: [
                "ScoutCore",
                "ScoutTestSupport",
            ]
        ),
        .testTarget(
            name: "ConnectorNativeTests",
            dependencies: [
                "ConnectorNative",
                "ScoutTestSupport",
                .product(name: "ScoutDBTesting", package: "scout-db"),
            ]
        ),
        .testTarget(
            name: "ConnectorHostedTests",
            dependencies: [
                "ConnectorHosted",
                "ScoutTestSupport",
            ]
        ),
        .testTarget(
            name: "ScoutUITests",
            dependencies: [
                "ScoutUI",
                "ConnectorHosted",
                "ScoutTestSupport",
            ]
        ),
        .testTarget(
            name: "ScoutCacheTests",
            dependencies: [
                "ScoutCache",
                "ScoutCore",
            ],
            // ScoutCache autolinks SwiftData (iOS 17+), so a bundle linking it fails
            // to load on the iOS 16 simulator. Weak-link the framework so the bundle
            // loads; the SwiftData suites are @available(iOS 17)-gated and skip there.
            linkerSettings: [.unsafeFlags(["-weak_framework", "SwiftData"])]
        ),
        .testTarget(
            name: "ScoutSnapshotTests",
            dependencies: [
                "ScoutUI",
                "ScoutCore",
                "ScoutTestSupport",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
)
