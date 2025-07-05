import ProjectDescription

let project = Project(
    name: "CommonFeature",
    packages: [],
    targets: [
        .target(
            name: "CommonFeature",
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
                // External dependencies from Package.swift
                .external(name: "Mixpanel"),
                .external(name: "FirebaseAnalytics"),
                .external(name: "ComposableArchitecture"),
                .external(name: "GoogleMobileAds"),
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
