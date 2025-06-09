// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [:]
    )
#endif

let package = Package(
    name: "Apps",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", exact: "1.0.0"),
        .package(
            url: "https://github.com/akaffenberger/firebase-ios-sdk-xcframeworks.git",
            exact: "10.23.0"
        ),
        // Add your own dependencies here:
        // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        // You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies
    ]
)
