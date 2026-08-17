// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "thread-gateway",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .library(name: "ThreadGateway", targets: ["ThreadGateway"]),
    .executable(name: "thread-gateway-reader", targets: ["ThreadGatewayReader"]),
    .executable(name: "thread-gateway-writer", targets: ["ThreadGatewayWriter"])
  ],
  targets: [
    .target(name: "ThreadGateway"),
    .executableTarget(
      name: "ThreadGatewayReader",
      dependencies: ["ThreadGateway"]
    ),
    .executableTarget(
      name: "ThreadGatewayWriter",
      dependencies: ["ThreadGateway"]
    ),
    .testTarget(
      name: "ThreadGatewayTests",
      dependencies: ["ThreadGateway"]
    )
  ],
  swiftLanguageModes: [.v6]
)
