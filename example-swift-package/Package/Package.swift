// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "BoostPackageExample",
    platforms: [.macOS(.v10_15)],
    products: [.executable(name: "BoostPackageExample", targets: ["BoostPackageExample"])],
    targets: [
        .binaryTarget(name: "boost", path: "boost.xcframework"),
        .target(name: "ofxOSXBoostBridge", dependencies: ["boost"], publicHeadersPath: "include"),
        .executableTarget(name: "BoostPackageExample", dependencies: ["ofxOSXBoostBridge"])
    ],
    cxxLanguageStandard: .cxx20
)
