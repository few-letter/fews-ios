import ProjectDescription

let project = Project(
    name: "FewCuts",
    packages: [],
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
                .project(target: "Shared_ThirdPartyLibs", path: "../../Modules/Shared/Shared_ThirdPartyLibs")
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "X64MATB2CC",
                    "CODE_SIGN_STYLE": "Automatic",
                    "PRODUCT_BUNDLE_IDENTIFIER": "com.annapo.fewcuts",
                    "OTHER_LDFLAGS": [
                        "$(inherited)", "-ObjC", "-Xlinker", "-interposable"
                    ],
                    "ENABLE_BITCODE": false
                ]
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
