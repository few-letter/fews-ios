//
//  Project.swift
//  Manifests
//
//  Created by 송영모 on 6/24/25.
//

import ProjectDescription

let project = Project(
    name: "Capts",
    packages: [
        .package(url: "https://github.com/ml-explore/mlx-swift", .upToNextMajor(from: "0.25.5")),
    ],
    targets: [
        .target(
            name: "Capts",
            destinations: .iOS,
            product: .app,
            bundleId: "com.folio.world.mulling.app.ios",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .file(path: "Resources/Info.plist"),
            sources: ["Sources/**"],
            resources: [
                .glob(pattern: "Resources/Assets.xcassets/**"),
            ],
            entitlements: "Resources/Capts.entitlements",
            dependencies: [
                .package(product: "MLX"),
                .package(product: "MLXNN"),
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
