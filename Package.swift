// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HaByLo",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "HaByLo",
            targets: ["HaByLo"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "HaByLo",
            dependencies: [
                .product(name: "NIOCore",
                         package: "swift-nio"),
            ]),
        .testTarget(
            name: "HaByLoTests",
            dependencies: ["HaByLo"]),
    ]
)
