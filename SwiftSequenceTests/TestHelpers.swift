import Foundation
import XCTest

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

func XCTAssertEqual<T : Equatable>(lhs: T)(_ rhs: T) {
  XCTAssertEqual(lhs, rhs)
}

func XCTAssertEqual<
  S0 : SequenceType, S1 : SequenceType where
  S0.Generator.Element == S1.Generator.Element,
  S0.Generator.Element : Equatable>(lhs: S0)(_ rhs:S1) {
  XCTAssert(lhs.elementsEqual(rhs),
    String(reflecting: lhs) + " does not equal " + String(reflecting: rhs))
}

struct WatcherSequence<S : SequenceType> : SequenceType {
  private let seq: S
  func generate() -> AnyGenerator<S.Generator.Element> {
    var g = seq.generate()
    var calledNil = false
    return anyGenerator {
      XCTAssertFalse(calledNil, "Called a generator after it had already returned nil")
      if let e = g.next() { return e }
      calledNil = true
      return nil
    }
  }
  internal init(_ s: S) {
    seq = s
  }
}

func fst<A,B>(t: (A,B)) -> A { return t.0 }
func snd<A,B>(t: (A,B)) -> B { return t.1 }