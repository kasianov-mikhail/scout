// swift-tools-version: 6.2
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
            name: "DemoConnector",
            targets: ["DemoConnector"]
        ),
        .executable(
            name: "scout-symbols",
            targets: ["ScoutSymbols"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.11.0"),
        .package(url: "https://github.com/apple/swift-metrics.git", from: "2.4.0"),
        .package(url: "https://github.com/kasianov-mikhail/scout-db.git", from: "0.4.0"),
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
                "SymbolTable",
            ],
            resources: [
                .process("Persistence/ScoutModel.xcdatamodeld"),
                .copy("PrivacyInfo.xcprivacy"),
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
                "SymbolTable",
                .product(name: "Logging", package: "swift-log"),
            ],
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ]
        ),
        .target(
            name: "SymbolTable",
            path: "Sources/ScoutSymbols/SymbolTable"
        ),
        .target(
            name: "DWARF",
            dependencies: [
                "SymbolTable"
            ],
            path: "Sources/ScoutSymbols/DWARF"
        ),
        .executableTarget(
            name: "ScoutSymbols",
            dependencies: [
                "DWARF",
                "SymbolTable",
            ],
            path: "Sources/ScoutSymbols/CLI"
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
                "SymbolTable",
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
                "SymbolTable",
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
            ],
            path: "Tests/ScoutSymbols/SymbolTable"
        ),
        .testTarget(
            name: "DWARFTests",
            dependencies: [
                "DWARF"
            ],
            path: "Tests/ScoutSymbols/DWARF",
            resources: [
                .copy("Fixtures")
            ]
        ),
    ]
)
