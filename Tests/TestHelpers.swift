import Darwin
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

private let charLetters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters)

extension Character: Randable {
  internal static var rand: Character {
    return charLetters[Int.randLim(charLetters.count)]
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

func XCTAssertEqualSeq<
  S0 : SequenceType, S1 : SequenceType where
  S0.Generator.Element == S1.Generator.Element,
  S0.Generator.Element : Equatable>(lhs: S0, _ rhs:S1) {
    var (g0,g1) = (lhs.generate(),rhs.generate())
    while true {
      guard let a = g0.next() else {
        guard case nil = g1.next() else {
          XCTFail(String(reflecting: lhs) + " is shorter than " + String(reflecting: rhs))
          return
        }
        return
      }
      guard let b = g1.next() else {
        XCTFail(String(reflecting: lhs) + " is shorter than " + String(reflecting: rhs))
        return
      }
      XCTAssert(a == b,
        String(a) + " does not equal " +
        String(b) + "\n" + "In the sequences: " +
        String(lhs) + " and " + String(reflecting: rhs)
      )
    }
}

func XCTAssertEqualNested<
  S0 : SequenceType, S1 : SequenceType where
  S0.Generator.Element : SequenceType,
  S1.Generator.Element : SequenceType,
  S0.Generator.Element.Generator.Element == S1.Generator.Element.Generator.Element,
  S0.Generator.Element.Generator.Element : Equatable>(lhs: S0, _ rhs:S1) {
  var (g0,g1) = (lhs.generate(),rhs.generate())
  while true {
    let (e0,e1) = (g0.next(),g1.next())
    guard let e0U = e0 else {
      if let _ = e1 {
        XCTFail(String(reflecting: lhs) + " is shorter than " + String(reflecting: rhs))
      }
      return
    }
    guard let e1U = e1 else {
      if let _ = e1 {
        XCTFail(String(reflecting: rhs) + " is shorter than " + String(reflecting: lhs))
      }
      return
    }
    XCTAssertEqualSeq(e0U, e1U)
  }
}

struct WatcherGenerator<G: GeneratorType>: GeneratorType {
  private var g: G
  private var p: Bool
  mutating func next() -> G.Element? {
    XCTAssertFalse(p, "Called a generator after it had already returned nil")
    if let e = g.next() { return e }
    p = true
    return nil
  }
}

struct WatcherSequence<S : SequenceType> : SequenceType {
  private let seq: S
  func generate() -> WatcherGenerator<S.Generator> {
    return WatcherGenerator(g: seq.generate(), p: false)
  }
  internal init(_ s: S) {
    seq = s
  }
}

func fst<A,B>(t: (A,B)) -> A { return t.0 }
func snd<A,B>(t: (A,B)) -> B { return t.1 }

private var facs = [1]

extension Int {
  var fac: Int {
    if self >= facs.endIndex {
      facs.append(predecessor().fac * self)
    }
    return facs[self]
  }
}

func choose(n: Int, _ r: Int) -> Int {
  let num = n.fac
  let den = r.fac * (n - r).fac
  return num / den
}

func chooseRep(n: Int, _ r: Int) -> Int {
  let num = (n + r - 1).fac
  let den = r.fac * (n - 1).fac
  return num / den
}