//
//  Project.swift
//  Manifests
//
//  Created by 송영모 on 6/24/25.
//

import ProjectDescription

let project = Project(
    name: "Multis",
    packages: [
        .package(url: "https://github.com/mixpanel/mixpanel-swift", .upToNextMajor(from: "5.1.0"))
    ],
    targets: [
        .target(
            name: "Multis",
            destinations: .iOS,
            product: .app,
            bundleId: "com.annapo.taskfolio",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .file(path: "Resources/Info.plist"),
            sources: ["Sources/**"],
            resources: [
                .glob(pattern: "Resources/Assets.xcassets/**"),
            ],
            entitlements: "Resources/Multis.entitlements",
            dependencies: [
                .package(product: "Mixpanel"),
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
