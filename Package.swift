// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "reithd",
  platforms: [
    .macOS(.v10_12),
  ],
  products: [
    .executable(
      name: "reithd",
      targets: ["reithd"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/nicklockwood/SwiftFormat",
      from: "0.44.2"
    ),
  ],
  targets: [
    .target(
      name: "reithd",
      dependencies: ["ReithDCore", "Commander"]
    ),
    .target(
      name: "ReithDCore",
      dependencies: []
    ),
    .testTarget(
      name: "ReithDCoreTests",
      dependencies: ["ReithDCore"]
    ),
  ]
)
