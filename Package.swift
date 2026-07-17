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
            name: "ScoutNative",
            targets: ["ScoutNative"]
        ),
        .library(
            name: "ScoutHosted",
            targets: ["ScoutHosted"]
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
            name: "CScoutHang"
        ),
        .target(
            name: "Scout",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Metrics", package: "swift-metrics"),
                "CScoutHang",
            ],
            resources: [
                .process("Persistence/ScoutModel.xcdatamodeld")
            ]
        ),
        .target(
            name: "ScoutNative",
            dependencies: [
                "Scout",
                .product(name: "ScoutDB", package: "scout-db"),
            ]
        ),
        .target(
            name: "ScoutHosted",
            dependencies: [
                "Scout"
            ]
        ),
        .target(
            name: "ScoutUI",
            dependencies: [
                "Scout"
            ]
        ),
        .target(
            name: "ScoutCache",
            dependencies: [
                "Scout"
            ]
        ),
        .target(
            name: "Support",
            dependencies: [
                "Scout"
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "ScoutTests",
            dependencies: [
                "Scout",
                "Support",
            ]
        ),
        .testTarget(
            name: "ScoutNativeTests",
            dependencies: [
                "ScoutNative",
                "Support",
                .product(name: "ScoutDBTesting", package: "scout-db"),
            ]
        ),
        .testTarget(
            name: "ScoutHostedTests",
            dependencies: [
                "ScoutHosted",
                "Support",
            ]
        ),
        .testTarget(
            name: "ScoutUITests",
            dependencies: [
                "ScoutUI",
                "ScoutHosted",
                "Support",
            ]
        ),
        .testTarget(
            name: "ScoutCacheTests",
            dependencies: [
                "ScoutCache",
                "Scout",
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
                "Scout",
                "Support",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
)
