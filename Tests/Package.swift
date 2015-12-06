import PackageDescription

let package = Package(
  name: "SwiftSequenceTests",
  dependencies: [
    .Package(url: "https://github.com/oisdk/SwiftSequence.git", majorVersion: 1),
    .Package(url: "https://github.com/apple/swift-corelibs-xctest.git", majorVersion: 1)
  ]
)