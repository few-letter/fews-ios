import ProjectDescription

let project = Project(
    name: "Toffs",
    packages: [],
    targets: [
        .target(
            name: "Toffs",
            destinations: .iOS,
            product: .app,
            bundleId: "com.tamsadan.toolinder",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .file(path: "Resources/Info.plist"),
            sources: ["Sources/**"],
            resources: [
                .glob(pattern: "Resources/Assets.xcassets/**"),
                .glob(pattern: "Resources/GoogleService-Info.plist")
            ],
            entitlements: "Resources/Toff.entitlements",
            dependencies: [
                .project(target: "DS", path: "../../Modules/DS"),
                .project(target: "CommonFeature", path: "../../Modules/CommonFeature"),
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
                        xcconfig: .path("Resources/Debug.xcconfig"),
                    ),
                    .release(
                        name: "Release",
                        settings: SettingsDictionary()
                            .automaticCodeSigning(devTeam: "X64MATB2CC"),
                        xcconfig: .path("Resources/Release.xcconfig")
                    )
                ]
            )
        )
    ]
) 
