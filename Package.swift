// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftConnection",
    products: [
        .library(
            name: "SwiftConnection",
            targets: ["SwiftConnection"]),
    ],
    targets: [
        .target(
            name: "SwiftConnection",
            dependencies: []),
        .testTarget(
            name: "SwiftConnectionTests",
            dependencies: ["SwiftConnection"]),
    ]
)
