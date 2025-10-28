// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "Stubby",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
  ],
  products: [
    .library(name: "Stubby", targets: ["Stubby"]),
    .library(name: "StubbyMacros", targets: ["StubbyMacros"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-macro-testing", .upToNextMajor(from: "0.6.4")),
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", .upToNextMajor(from: "1.4.5")),
    .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0"..<"603.0.0"),
  ],
  targets: [
    .target(
      name: "Stubby"
    ),
    .testTarget(
      name: "StubbyTests",
      dependencies: [
        "Stubby",
        "StubbyMacros",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
        .product(name: "MacroTesting", package: "swift-macro-testing"),
      ]
    ),
    .target(
      name: "StubbyMacros",
      dependencies: [
        "Stubby",
        "StubbyMacrosPlugin",
      ]
    ),
    .macro(
      name: "StubbyMacrosPlugin",
      dependencies: [
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
      ]
    ),
    .testTarget(
      name: "StubbyMacrosPluginTests",
      dependencies: [
        "StubbyMacros",
        "StubbyMacrosPlugin",
        .product(name: "MacroTesting", package: "swift-macro-testing"),
      ]
    ),
  ],
  swiftLanguageModes: [.v5]
)
