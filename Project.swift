import ProjectDescription

let projectName = "SnapshotTesting"

let project = Project(
    name: "\(projectName)Dev",
    packages: [
        .local(path: ".")
    ],
    targets: [
        .devTarget,
        .testTarget
    ],
    schemes: [
        Scheme(
            name: "\(projectName)Dev",
            shared: true,
            buildAction: .init(
                targets: [.project(path: ".", target: "\(projectName)Dev")]
            ),
            testAction: .testPlans([
                "TestPlans/AllTests.xctestplan"
            ])
        )
    ]
)

extension Target {
    static var devTarget: Target {
        Target(
            name: "\(projectName)Dev",
            platform: .iOS,
            product: .framework,
            bundleId: "com.oss.\(projectName)",
            infoPlist: .default,
            sources: [],
            scripts: [
                .post(script: .swiftLint, name: "Run SwiftLint")
            ],
            dependencies: [
                .package(product: projectName)
            ]
        )
    }

    static var testTarget: Target {
        Target(
            name: "\(projectName)DevTests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "com.oss.\(projectName)Tests",
            infoPlist: .default,
            dependencies: [
                .package(product: projectName)
            ]
        )
    }
}

extension String {
    static let swiftLint = """
    # Apple Silicon Homebrew directory
    export PATH="$PATH:/opt/homebrew/bin"

    if which swiftlint >/dev/null; then
        swiftlint
    else
        echo "SwiftLint is not installed. Please run 'make setup'"
        exit 1
    fi
    """
}
