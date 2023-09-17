// swift-tools-version: 5.8
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
  targets: [
    .target(
      name: "Stubby",
      dependencies: []),
    .testTarget(
      name: "StubbyTests",
      dependencies: [
        .target(name: "Stubby"),
      ]),
  ]
)
