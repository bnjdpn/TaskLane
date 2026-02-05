// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "TaskLane",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v15)  // macOS 26 equivalent - will update when SDK available
    ],
    products: [
        .executable(name: "TaskLane", targets: ["TaskLane"])
    ],
    dependencies: [
        // ViewInspector temporarily removed - causes SIGSEGV on CI
        // .package(url: "https://github.com/nalexn/ViewInspector", from: "0.10.0")
    ],
    targets: [
        .executableTarget(
            name: "TaskLane",
            path: "TaskLane",
            resources: [
                .process("Resources"),
                .process("Localization")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)  // Use Swift 5 mode until full Swift 6 migration
            ]
        ),
        .testTarget(
            name: "TaskLaneTests",
            dependencies: [
                "TaskLane"
                // ViewInspector temporarily removed - causes SIGSEGV on CI
            ],
            path: "Tests/TaskLaneTests",
            swiftSettings: [
                .swiftLanguageMode(.v5)  // Match main target's language mode
            ]
        )
    ]
)
