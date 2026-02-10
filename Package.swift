// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "UsefulThingsPointFree",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v16),
    ],
    products: [
        .library(name: "AccessibilityPermissionDependency", targets: ["AccessibilityPermissionDependency"]),
        .library(name: "ClipboardDependency", targets: ["ClipboardDependency"]),
        .library(name: "FilePanelsClient", targets: ["FilePanelsClient"]),
        .library(name: "FilesClient", targets: ["FilesClient"]),
        .library(name: "SwiftUIEnvironmentDependencies", targets: ["SwiftUIEnvironmentDependencies"]),
        .library(name: "SFSpeechDependency", targets: ["SFSpeechDependency"]),
        .library(name: "SystemSoundClient", targets: ["SystemSoundClient"]),
        .library(name: "TCAComponents", targets: ["TCAComponents"]),
        .library(name: "UserNotificationsDependency", targets: ["UserNotificationsDependency"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.6.2"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.17.0"),
    ],
    targets: [
        .target(
            name: "AccessibilityPermissionDependency",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "ClipboardDependency",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
        .target(
            name: "FilePanelsClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
        .target(
            name: "FilesClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
        .target(
            name: "SwiftUIEnvironmentDependencies",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
        .target(
            name: "SFSpeechDependency",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
        .target(
            name: "SystemSoundClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "TCAComponents",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "UserNotificationsDependency",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
            ]
        ),
    ]
)
