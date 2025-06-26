import ProjectDescription

let project = Project(
    name: "FewCuts",
    packages: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.0.0")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "1.20.0")),
        .package(url: "https://github.com/ml-explore/mlx-swift", .upToNextMajor(from: "0.18.0"))
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
            dependencies: [
                .package(product: "FirebaseAuth"),
                .package(product: "FirebaseFirestore"),
                .package(product: "ComposableArchitecture"),
                .package(product: "MLX"),
                .package(product: "MLXNN")
            ],
            settings: .settings(
                base: SettingsDictionary()
                    .merging([
                        "DEVELOPMENT_TEAM": "X64MATB2CC",
                        "CODE_SIGN_STYLE": "Automatic",
                        "PRODUCT_BUNDLE_IDENTIFIER": "com.annapo.fewcuts",
                        "OTHER_LDFLAGS": [
                            "-Xlinker", "-interposable"
                        ],
                        "ENABLE_BITCODE": false
                    ])
            )
        ),
        .target(
            name: "FewCutsTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.annapo.fewcuts.tests",
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "FewCuts")
            ]
        )
    ]
) 
