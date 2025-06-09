import ProjectDescription

let project = Project(
    name: "Toff",
    targets: [
        .target(
            name: "Toff",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.Toff",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "CFBundleDisplayName": "Toff"
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "DS", path: "../../Modules/DS")
            ]
        ),
        .target(
            name: "ToffTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.ToffTests",
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "Toff")]
        ),
    ]
) 
