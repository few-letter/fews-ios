import ProjectDescription

let project = Project(
    name: "Retros",
    packages: [],
    targets: [
        .target(
            name: "Retros",
            destinations: .iOS,
            product: .app,
            bundleId: "com.annapo.kpt",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .file(path: "Resources/Info.plist"),
            sources: ["Sources/**"],
            resources: [
                .glob(pattern: "Resources/Assets.xcassets/**"),
            ],
            entitlements: "Resources/Retros.entitlements",
            dependencies: [
                .project(target: "Shared_ThirdPartyLibs", path: "../../Modules/Shared/Shared_ThirdPartyLibs"),
                .project(target: "Feature_Common", path: "../../Modules/Features/Feature_Common"),
                .sdk(name: "JavaScriptCore", type: .framework)
            ],
            settings: .settings(
                base: [
                    "OTHER_LDFLAGS": ["-ObjC"]
                ],
                configurations: [
                    .debug(
                        name: "Debug",
                        settings: SettingsDictionary()
                            .automaticCodeSigning(devTeam: "X64MATB2CC"),
                        xcconfig: .path("Resources/Debug.xcconfig")
                    ),
                    .release(
                        name: "Release",
                        settings: SettingsDictionary()
                            .automaticCodeSigning(devTeam: "X64MATB2CC"),
                        xcconfig: .path("Resources/Release.xcconfig")
                    )
                ]
            )
        ),
    ]
)
