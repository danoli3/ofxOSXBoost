// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Boost",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "ofxOSXBoost", targets: ["ofxOSXBoost"]),
        .library(name: "boost", targets: ["boost"])
    ],
    targets: [
        .binaryTarget(
            name: "boost",
            url: "https://github.com/danoli3/ofxOSXBoost/releases/download/1.92.0/ofxOSXBoost-1.92.0-xcframework.zip",
            checksum: "0000000000000000000000000000000000000000000000000000000000000000"
        ),
        .target(
            name: "ofxOSXBoost",
            dependencies: ["boost"],
            path: "example-swift-package/Package/Sources/ofxOSXBoostBridge",
            publicHeadersPath: "include"
        )
    ],
    cxxLanguageStandard: .cxx20
)
