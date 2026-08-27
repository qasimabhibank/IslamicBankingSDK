// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IslamicBankingSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "IslamicBankingSDK",
            targets: ["IslamicBankingSDK"]
        )
    ],
    targets: [
        .target(
            name: "IslamicBankingSDK",
            path: "Sources/IslamicBankingSDK",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
