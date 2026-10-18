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
        .library(
            name: "DemoConnector",
            targets: ["DemoConnector"]
        ),
        .executable(
            name: "scout-symbols",
            targets: ["ScoutSymbols"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-metrics.git", "1.0.0"..<"3.0.0"),
        .package(
            url: "https://github.com/kasianov-mikhail/scout-db.git",
            revision: "0e3523903090c2673cc971e27d65c4a92cdaf41a"
        ),
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
            name: "ConnectorSupport",
            dependencies: [
                "Scout"
            ],
            path: "Sources/Connectors/Support"
        ),
        .target(
            name: "NativeConnector",
            dependencies: [
                "Scout",
                "ConnectorSupport",
                .product(name: "ScoutDB", package: "scout-db"),
            ],
            path: "Sources/Connectors/Native"
        ),
        .target(
            name: "HostedConnector",
            dependencies: [
                "Scout",
                "ConnectorSupport",
            ],
            path: "Sources/Connectors/Hosted"
        ),
        .target(
            name: "ScoutUI",
            dependencies: [
                "Scout",
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .target(
            name: "LookupIndex"
        ),
        .target(
            name: "SymbolTable"
        ),
        .target(
            name: "DWARF",
            dependencies: [
                "SymbolTable"
            ]
        ),
        .executableTarget(
            name: "ScoutSymbols",
            dependencies: [
                "DWARF",
                "SymbolTable",
            ]
        ),
        .target(
            name: "DemoConnector",
            dependencies: [
                "Scout",
                "ConnectorSupport",
            ],
            path: "Sources/Connectors/Demo"
        ),
        .target(
            name: "Support",
            dependencies: [
                "Scout",
                "ConnectorSupport",
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
            name: "ConnectorSupportTests",
            dependencies: [
                "ConnectorSupport",
                "Support",
            ],
            path: "Tests/Connectors/Support"
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
                "ConnectorSupport",
                "Support",
            ]
        ),
        .testTarget(
            name: "DemoConnectorTests",
            dependencies: [
                "DemoConnector",
                "ScoutUI",
                "Scout",
                "Support",
            ],
            path: "Tests/Connectors/Demo"
        ),
        .testTarget(
            name: "SymbolTableTests",
            dependencies: [
                "SymbolTable"
            ]
        ),
        .testTarget(
            name: "DWARFTests",
            dependencies: [
                "DWARF"
            ],
            resources: [
                .copy("Fixtures")
            ]
        ),
    ]
)
