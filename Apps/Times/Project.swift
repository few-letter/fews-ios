//
//  Project.swift
//  Manifests
//
//  Created by 송영모 on 6/24/25.
//

import ProjectDescription

let project = Project(
    name: "Times",
    packages: [],
    targets: [
        .target(
            name: "Times",
            destinations: .iOS,
            product: .app,
            bundleId: "annapo.HTG",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .file(path: "Resources/Info.plist"),
            sources: ["Sources/**"],
            resources: [
                .glob(pattern: "Resources/Assets.xcassets/**"),
            ],
            entitlements: "Resources/Times.entitlements",
            dependencies: [
                
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
