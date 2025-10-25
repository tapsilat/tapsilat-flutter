// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "tapsilat_macos",
  platforms: [
    .macOS("10.15")
  ],
  products: [
    .library(name: "tapsilat-macos", targets: ["tapsilat"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "tapsilat",
      dependencies: []
    )
  ]
)
