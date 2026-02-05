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
    targets: [
        .executableTarget(
            name: "TaskLane",
            path: "TaskLane",
            resources: [
                .process("Resources"),
                .process("Localization")
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        )
    ]
)
