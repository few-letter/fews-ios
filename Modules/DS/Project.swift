import ProjectDescription

let project = Project(
    name: "DS",
    targets: [
        .target(
            name: "DS",
            destinations: .iOS,
            product: .framework,
            bundleId: "io.tuist.DS",
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: [],
            dependencies: []
        ),
        .target(
            name: "DSTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.DSTests",
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "DS")]
        ),
    ]
) 