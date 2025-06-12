import ProjectDescription

let project = Project(
    name: "Connects",
    packages: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.0.0")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "1.20.0"))
    ],
    targets: [
        .target(
            name: "Connects",
            destinations: .macOS,
            product: .app,
            bundleId: "com.annapo.connects",
            infoPlist: .file(path: "Resources/Info.plist"),
            sources: ["Sources/**"],
            resources: [
                .glob(pattern: "Resources/Assets.xcassets/**"),
                .glob(pattern: "Resources/GoogleService-Info.plist")
            ],
            entitlements: "Resources/Connects.entitlements", dependencies: [
                .package(product: "FirebaseAnalytics"),
                .package(product: "ComposableArchitecture")
            ],
            settings: .settings(configurations: [
                .debug(
                    name: "Debug",
                    settings: SettingsDictionary().automaticCodeSigning(devTeam: "X64MATB2CC")
                ),
                .release(
                    name: "Release",
                    settings: SettingsDictionary().automaticCodeSigning(devTeam: "X64MATB2CC")
                )
            ])
        ),
    ]
)
