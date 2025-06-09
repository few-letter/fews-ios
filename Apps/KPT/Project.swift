import ProjectDescription

let project = Project(
    name: "KPT",
    packages: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.0.0")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "1.20.0"))
    ],
    targets: [
        .target(
            name: "KPT",
            destinations: .iOS,
            product: .app,
            bundleId: "com.annapo.kpt",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "CFBundleDisplayName": "KPT",
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ],
                    "NSUserTrackingUsageDescription": "이 앱은 더 나은 사용자 경험을 제공하기 위해 사용자 데이터를 추적합니다.",
                    "UIBackgroundModes": ["remote-notification"]
                ]
            ),
            sources: ["Sources/**"],
            resources: [
                .glob(pattern: "Resources/Assets.xcassets/**"),
                .glob(pattern: "Resources/GoogleService-Info.plist")
            ],
            entitlements: "Resources/kpt.entitlements",
            dependencies: [
                .project(target: "DS", path: "../../Modules/DS"),
                .package(product: "FirebaseAnalytics"),
                .package(product: "ComposableArchitecture")
            ]
        ),
        .target(
            name: "KPTTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.KPTTests",
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "KPT")]
        ),
    ]
) 
