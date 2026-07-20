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
            name: "NativeConnector",
            targets: ["NativeConnector"]
        ),
        .library(
            name: "HostedConnector",
            targets: ["HostedConnector"]
        ),
        .library(
            name: "ScoutUI",
            targets: ["ScoutUI"]
        ),
        .library(
            name: "LookupIndex",
            targets: ["LookupIndex"]
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
            name: "NativeConnector",
            dependencies: [
                "Scout",
                .product(name: "ScoutDB", package: "scout-db"),
            ],
            path: "Sources/Connectors/Native"
        ),
        .target(
            name: "HostedConnector",
            dependencies: [
                "Scout"
            ],
            path: "Sources/Connectors/Hosted"
        ),
        .target(
            name: "ScoutUI",
            dependencies: [
                "Scout"
            ]
        ),
        .target(
            name: "LookupIndex",
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
            name: "NativeConnectorTests",
            dependencies: [
                "NativeConnector",
                "Support",
                .product(name: "ScoutDBTesting", package: "scout-db"),
            ],
            path: "Tests/Connectors/Native"
        ),
        .testTarget(
            name: "HostedConnectorTests",
            dependencies: [
                "HostedConnector",
                "Support",
            ],
            path: "Tests/Connectors/Hosted"
        ),
        .testTarget(
            name: "ScoutUITests",
            dependencies: [
                "ScoutUI",
                "HostedConnector",
                "Support",
            ]
        ),
        .testTarget(
            name: "LookupIndexTests",
            dependencies: [
                "LookupIndex",
                "Scout",
            ]
            // LookupIndex autolinks SwiftData (iOS 17+), so this bundle can't load
            // on the iOS 16 simulator; the `swift.yml` iOS 16 leg skips it entirely.
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
