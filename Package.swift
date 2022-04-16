// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MatrixSQLiteStore",
    platforms: [
        .iOS(.v15), .tvOS(.v15),
        .watchOS(.v8), .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MatrixSQLiteStore",
            targets: ["MatrixSQLiteStore"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "MatrixCore", path: "/Users/kloenk/Developer/Xcode/MatrixCore"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "5.23.0")
    ],
    targets: [
        .target(
            name: "MatrixSQLiteStore",
            dependencies: [
                .product(name: "MatrixCore", package: "MatrixCore"),
                .product(name: "MatrixClient", package: "MatrixCore"),
                .product(name: "GRDB", package: "GRDB.swift")
            ]),
        .testTarget(
            name: "MatrixSQLiteStoreTests",
            dependencies: ["MatrixSQLiteStore"]),
    ]
)
