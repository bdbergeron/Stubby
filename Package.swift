// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Stubby",
  platforms: [
    .macOS(.v10_13),
    .iOS(.v12),
  ],
  products: [
    .library(name: "Stubby", targets: ["Stubby"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-docc-plugin", .upToNextMajor(from: "1.4.5")),
  ],
  targets: [
    .target(
      name: "Stubby",
      dependencies: []
    ),
    .testTarget(
      name: "StubbyTests",
      dependencies: [
        .target(name: "Stubby"),
      ]
    ),
  ]
)
