import Foundation

internal protocol Randable {
  static var rand: Self { get }
}

extension Int: Randable {
  internal static var rand: Int {
    return Int(arc4random_uniform(UInt32.max))
  }
  internal static func randLim(lim: Int) -> Int {
    return Int(arc4random_uniform(UInt32(lim)))
  }
}

extension Array where Element : Randable {
  internal init(randLength: Int) {
    self = (0..<randLength).map { _ in Element.rand }
  }
}

func randPred() -> (Int -> Bool) {
  let d = Int.randLim(20) + 1
  return { n in n % d == 0 }
}