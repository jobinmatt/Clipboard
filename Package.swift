// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClipboardHistory",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "ClipboardHistory", targets: ["ClipboardHistory"])
    ],
    targets: [
        .executableTarget(
            name: "ClipboardHistory",
            path: "Sources/ClipboardHistory"
        )
    ]
)
