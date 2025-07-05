// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // Firebase와 Google libraries를 위한 product type 설정
        // FBLPromises는 dynamic framework로 설정하여 런타임 크래시 방지
        productTypes: [
            "FBLPromises": .framework,
        ]
    )
#endif

let package = Package(
    name: "PackageName",
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.0.0")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "1.20.0")),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", .upToNextMajor(from: "12.6.0")),
        .package(url: "https://github.com/mixpanel/mixpanel-swift", .upToNextMajor(from: "5.1.0")),
        .package(url: "https://github.com/ml-explore/mlx-swift", .upToNextMajor(from: "0.18.0"))
    ]
) 