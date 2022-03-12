// swift-tools-version:5.4
import Foundation
import PackageDescription

let package = Package(
    name: "swift-snapshot-testing",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
        .tvOS(.v11)
    ],
    products: [
        .library(
            name: "SnapshotTesting",
            targets: ["SnapshotTesting"]
        )
    ],
    targets: [
        .target(
            name: "SnapshotTesting",
            dependencies: []
        ),
        .testTarget(
            name: "SnapshotTestingTests",
            dependencies: ["SnapshotTesting"],
            exclude: [
                "__Fixtures__",
                "__Snapshots__"
            ]
        )
    ]
)

if ProcessInfo.processInfo.environment.keys.contains("PF_DEVELOP") {
    package.dependencies.append(
        contentsOf: [
            .package(url: "https://github.com/yonaskolb/XcodeGen.git", .exact("2.15.1"))
        ]
    )
}
