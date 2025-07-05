import ProjectDescription

let project = Project(
    name: "Feature_Common",
    packages: [],
    targets: [
        .target(
            name: "Feature_Common",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.annapo.few.feature",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: [
                .glob(pattern: "Resources/Assets.xcassets/**"),
            ],
            dependencies: [
                .project(target: "Shared_ThirdPartyLibs", path: "../../Shared/Shared_ThirdPartyLibs"),
                .sdk(name: "JavaScriptCore", type: .framework)
            ],
            settings: .settings(
                base: [
                    "OTHER_LDFLAGS": ["-ObjC"]
                ]
            )
        ),
    ]
)
