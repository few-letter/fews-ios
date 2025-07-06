//
//  Project.swift
//  Manifests
//
//  Created by 송영모 on 7/6/25.
//

import ProjectDescription

let project = Project(
    name: "LegacyPlots",
    packages: [],
    targets: [
        .target(
            name: "LegacyPlots",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.annapo.legacyplots",
            sources: ["Sources/**"],
            resources: [
                .glob(pattern: "Resources/plotfolio.xcdatamodeld"),
            ],
            dependencies: [
                .project(target: "Shared_ThirdPartyLibs", path: "../../../Modules/Shared/Shared_ThirdPartyLibs"),
                .project(target: "Feature_Common", path: "../../../Modules/Features/Feature_Common"),
            ]
        ),
    ]
)
