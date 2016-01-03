Pod::Spec.new do |s|
  s.name             = "SwiftSequence"
  s.version          = "0.1.0"
  s.summary          = "A μframework of extensions for SequenceType in Swift 2.0, inspired by Python's itertools, Haskell's standard library, and other things."
  s.description      = "SwiftSequence is a lightweight framework of extensions to SequenceType. It has no requirements beyond the Swift standard library. Every function and method has both a strict and a lazy version, unless otherwise specified."

  s.homepage         = "https://github.com/oisdk/SwiftSequence"
  s.license          = 'MIT'
  s.author           = { "Donnacha Oisin Kidney" => "https://github.com/oisdk" }
  s.source           = { :git => "https://github.com/oisdk/SwiftSequence.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/oisdk'

  s.requires_arc = true

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'Sources/*.swift'
end
