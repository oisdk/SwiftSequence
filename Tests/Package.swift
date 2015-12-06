import PackageDescription

let package = Package(
  name: "SwiftSequenceTests",
  dependencies: [
    .Package(url: "https://github.com/oisdk/SwiftSequence/tree/Package.git", majorVersion: 1),
    .Package(url: "https://github.com/apple/swift-corelibs-xctest", majorVersion: 1)
  ]
)