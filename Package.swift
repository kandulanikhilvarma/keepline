// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KeeplineCore",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [.library(name: "KeeplineCore", targets: ["KeeplineCore"])],
    targets: [
        .target(name: "KeeplineCore", path: "Sources/KeeplineCore"),
        .testTarget(name: "KeeplineCoreTests", dependencies: ["KeeplineCore"], path: "Tests/KeeplineCoreTests")
    ]
)
