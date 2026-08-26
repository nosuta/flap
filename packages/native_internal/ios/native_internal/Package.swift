// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "native_internal",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "native-internal", type: .static, targets: ["native_internal"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .binaryTarget(
            name: "libflap",
            path: "Frameworks/native_internal.xcframework"
        ),
        .target(
            name: "native_internal",
            dependencies: [
                "libflap",
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-u", "-Xlinker", "_InitializeDartAPI"]),
                .unsafeFlags(["-Xlinker", "-u", "-Xlinker", "_RPC"])
            ]
        )
    ]
)
