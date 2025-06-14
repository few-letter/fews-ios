import ProjectDescription

let project = Project(
    name: "Toff",
    targets: [
        .target(
            name: "Toff",
            destinations: .iOS,
            product: .app,
            bundleId: "com.tamsadan.toolinder",
            infoPlist: .file(path: "Resources/Info.plist"),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "DS", path: "../../Modules/DS")
            ],
            settings: .settings(configurations: [
                .debug(
                    name: "Debug",
                    settings: SettingsDictionary().automaticCodeSigning(devTeam: "X64MATB2CC"),
                ),
                .release(
                    name: "Release",
                    settings: SettingsDictionary().automaticCodeSigning(devTeam: "X64MATB2CC"),
                )
            ])
        )
    ]
) 
