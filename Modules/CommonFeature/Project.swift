import ProjectDescription

let project = Project(
    name: "CommonFeature",
    packages: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.0.0")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "1.20.0")),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", .upToNextMajor(from: "12.6.0")),
        .package(url: "https://github.com/mixpanel/mixpanel-swift", .upToNextMajor(from: "5.1.0"))
    ],
    targets: [
        .target(
            name: "CommonFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.annapo.few.feature",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: [
                .glob(pattern: "Resources/Assets.xcassets/**"),
            ],
            dependencies: [
                .package(product: "Mixpanel"),
                .package(product: "FirebaseAnalytics"),
                .package(product: "ComposableArchitecture"),
                .package(product: "GoogleMobileAds"),
                .sdk(name: "JavaScriptCore", type: .framework)
            ],
            settings: .settings(
                base: [
                    "OTHER_LDFLAGS": ["-ObjC"]
                ]
            )
        ),
    ]
)
