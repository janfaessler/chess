// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SwiftChessCore",
    platforms: [
        .macOS("26.0"),
        .iOS("26.0")
    ],
    products: [
        .library(name: "SwiftChessCore", targets: ["SwiftChessCore"])
    ],
    targets: [
        .target(name: "SwiftChessCore"),
        .testTarget(
            name: "SwiftChessCoreTests",
            dependencies: ["SwiftChessCore"]
        )
    ]
)
