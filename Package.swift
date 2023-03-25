// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CameraControlARView",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "CameraControlARView",
            targets: ["CameraControlARView"]
        ),
    ],
    dependencies: [
        // Swift-DocC Plugin - swift 5.6 ONLY (GitHhub Actions on 3/15/2022 only supports to 5.5)
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CameraControlARView",
            dependencies: []
        ),
        .testTarget(
            name: "CameraControlARViewTests",
            dependencies: ["CameraControlARView"]
        ),
    ]
)
