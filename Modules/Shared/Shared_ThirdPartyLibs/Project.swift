import ProjectDescription

let project = Project(
    name: "Shared_ThirdPartyLibs",
    packages: [
        .remote(url: "https://github.com/firebase/firebase-ios-sdk.git", requirement: .upToNextMajor(from: "10.0.0")),
        .remote(url: "https://github.com/pointfreeco/swift-composable-architecture", requirement: .upToNextMajor(from: "1.20.0")),
        .remote(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", requirement: .upToNextMajor(from: "12.6.0")),
        .remote(url: "https://github.com/mixpanel/mixpanel-swift", requirement: .upToNextMajor(from: "5.1.0")),
        .remote(url: "https://github.com/ml-explore/mlx-swift", requirement: .upToNextMajor(from: "0.18.0"))
    ],
    targets: [
        .target(
            name: "Shared_ThirdPartyLibs",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.annapo.few.thirdparty",
            sources: ["Sources/**"],
            dependencies: [
                .package(product: "FirebaseAnalytics"),
                .package(product: "FirebaseCrashlytics"),
                .package(product: "FirebaseRemoteConfig"),
                .package(product: "ComposableArchitecture"),
                .package(product: "GoogleMobileAds"),
                .package(product: "Mixpanel"),
                .package(product: "MLX"),
                .package(product: "MLXNN"),
                .package(product: "MLXOptimizers"),
                .package(product: "MLXRandom"),
                .package(product: "MLXFFT"),
                .sdk(name: "JavaScriptCore", type: .framework)
            ],
            settings: .settings(
                base: [
                    "OTHER_LDFLAGS": ["-ObjC"]
                ]
            )
        )
    ]
)