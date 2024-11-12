// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Scout",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Scout",
            targets: ["Scout"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Scout",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .testTarget(
            name: "ScoutTests",
            dependencies: ["Scout"]
        ),
    ]
)
