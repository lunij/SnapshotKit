// swift-tools-version:5.4
import Foundation
import PackageDescription

let package = Package(
    name: "SnapshotKit",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
        .tvOS(.v11),
        .watchOS("7.4")
    ],
    products: [
        .library(
            name: "SnapshotKit",
            targets: ["SnapshotKit"]
        )
    ],
    targets: [
        .target(
            name: "SnapshotKit",
            dependencies: []
        ),
        .testTarget(
            name: "SnapshotKitTests",
            dependencies: ["SnapshotKit"],
            exclude: [
                "__Fixtures__",
                "__Snapshots__"
            ]
        )
    ]
)
