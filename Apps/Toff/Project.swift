import ProjectDescription

let project = Project(
    name: "Toff",
    packages: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.0.0")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "1.20.0")),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", .upToNextMajor(from: "12.6.0"))
    ],
    targets: [
        .target(
            name: "Toff",
            destinations: .iOS,
            product: .app,
            bundleId: "com.tamsadan.toolinder",
            infoPlist: .file(path: "Resources/Info.plist"),
            sources: ["Sources/**"],
            resources: [
                .glob(pattern: "Resources/Assets.xcassets/**"),
                .glob(pattern: "Resources/GoogleService-Info.plist")
            ],
            dependencies: [
                .package(product: "FirebaseAnalytics"),
                .package(product: "ComposableArchitecture"),
                .package(product: "GoogleMobileAds")
            ],
            settings: .settings(configurations: [
                .debug(
                    name: "Debug",
                    settings: SettingsDictionary().automaticCodeSigning(devTeam: "X64MATB2CC"),
                ),
                .release(
                    name: "Release",
                    settings: SettingsDictionary().automaticCodeSigning(devTeam: "X64MATB2CC"),
                )
            ])
        )
    ]
) 
