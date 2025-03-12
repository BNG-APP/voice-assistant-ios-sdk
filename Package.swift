// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "VoiceAssistant",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "VoiceAssistant",
            targets: ["VoiceAssistant"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/socketio/socket.io-client-swift.git")
    ],
    targets: [
        .target(
            name: "VoiceAssistant",
            dependencies: [
                .product(name: "SocketIO", package: "socket.io-client-swift")
            ],
            path: "VoiceAssistant-iOS/VoiceAssistant-iOS/Sources",
            exclude: [],
            resources: [],
            publicHeadersPath: "include",
            cSettings: [],
            swiftSettings: [],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit"),
                .linkedFramework("AVFoundation")
            ]
        )
    ]
)

