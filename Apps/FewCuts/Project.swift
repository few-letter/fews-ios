import ProjectDescription

let project = Project(
    name: "FewCuts",
    packages: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.0.0")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "1.20.0"))
    ],
    targets: [
        .target(
            name: "FewCuts",
            destinations: .iOS,
            product: .app,
            bundleId: "com.annapo.fewcuts",
            infoPlist: .file(path: "Resources/Info.plist"),
            sources: ["Sources/**"],
            resources: [
                .glob(pattern: "Resources/Assets.xcassets/**"),
                .glob(pattern: "Resources/GoogleService-Info.plist")
            ],
            entitlements: "Resources/fewcuts.entitlements",
            dependencies: [
                .project(target: "DS", path: "../../Modules/DS"),
                .package(product: "FirebaseAnalytics"),
                .package(product: "ComposableArchitecture")
            ]
        ),
        .target(
            name: "FewCutsTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.FewCutsTests",
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "FewCuts")]
        ),
    ]
) 
