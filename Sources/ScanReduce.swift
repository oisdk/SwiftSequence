// MARK: - Eager

public extension SequenceType {
  
  // MARK: Reduce1
  
  /// Return the result of repeatedly calling combine with an accumulated value
  /// initialized to the first element of self and each element of self, in turn, i.e.
  /// return combine(combine(...combine(combine(self[0], self[1]),
  /// self[2]),...self[count-2]), self[count-1]).
  /// ```swift
  /// [1, 2, 3].reduce(+) // 6
  /// ```
  @warn_unused_result
  func reduce
    (@noescape combine: (accumulator: Generator.Element, element: Generator.Element) throws -> Generator.Element)
    rethrows -> Generator.Element? {
      var g = generate()
      guard let a = g.next() else { return nil }
      var accu = a
      while let next = g.next() {
        accu = try combine(accumulator: accu, element: next)
      }
      return accu
  }
  
  // MARK: Scan
  
  /// Return an array where every value is equal to combine called on the previous
  /// element, and the current element. The first element is taken to be initial.
  /// ```swift
  /// [1, 2, 3].scan(0, combine: +)
  /// 
  /// [1, 3, 6]
  /// ```
  @warn_unused_result
  func scan<T>(initial: T, @noescape combine: (accumulator: T, element: Generator.Element) throws -> T) rethrows -> [T] {
    var accu = initial
    return try map { e in
      accu = try combine(accumulator: accu, element: e)
      return accu
    }
  }
  
  // MARK: Scan1
  
  /// Return an array where every value is equal to combine called on the previous
  /// element, and the current element.
  /// ```swift
  /// [1, 2, 3].scan(+)
  ///
  /// [3, 6]
  /// ```
  @warn_unused_result
  func scan(@noescape combine: (accumulator: Generator.Element, element: Generator.Element) throws -> Generator.Element) rethrows -> [Generator.Element] {
    var g = generate()
    guard let i = g.next() else { return [] }
    return try GeneratorSequence(g).scan(i, combine: combine)
  }
}

// MARK: - Lazy

// MARK: Scan

/// :nodoc:
public struct ScanGen<G : GeneratorType, T> : GeneratorType {
  
  private let combine: (T, G.Element) -> T
  private var initial: T
  private var g: G
  /// :nodoc:
  public mutating func next() -> T? {
    guard let e = g.next() else { return nil }
    initial = combine(initial, e)
    return initial
  }
}

/// :nodoc:
public struct LazyScanSeq<S : SequenceType, T> : LazySequenceType {
  
  private let seq    : S
  private let combine: (T, S.Generator.Element) -> T
  private let initial: T
  /// :nodoc:
  public func generate() -> ScanGen<S.Generator, T> {
    return ScanGen(combine: combine, initial: initial, g: seq.generate())
  }
}

public extension LazySequenceType {
  
  /// Return a lazy sequence where every value is equal to combine called on the previous
  /// element, and the current element. The first element is taken to be initial.
  /// ```swift
  /// lazy([1, 2, 3]).scan(0, combine: +)
  ///
  /// 1, 3, 6
  /// ```
  @warn_unused_result
  func scan<T>(initial: T, combine: (accumulator: T, element: Generator.Element) -> T) -> LazyScanSeq<Self, T> {
    return LazyScanSeq(seq: self, combine: combine, initial: initial)
  }
}

// MARK: Scan1
/// :nodoc:
public struct Scan1Gen<G : GeneratorType> : GeneratorType {
  
  private let combine: (G.Element, G.Element) -> G.Element
  private var accu: G.Element?
  private var g: G
  
  public mutating func next() -> G.Element? {
    guard let a = accu, e = g.next() else { return nil }
    accu = combine(a, e)
    return accu!
  }
  
  private init(combine: (G.Element, G.Element) -> G.Element, generator: G) {
    g = generator
    self.combine = combine
    accu = g.next()
  }
}
/// :nodoc:
public struct LazyScan1Seq<S : SequenceType> : LazySequenceType {
  
  private let seq: S
  private let combine: (S.Generator.Element, S.Generator.Element) -> S.Generator.Element
  /// :nodoc:
  public func generate() -> Scan1Gen<S.Generator> {
    return Scan1Gen(combine: combine, generator: seq.generate())
  }
}

public extension LazySequenceType {
  
  /// Return a lazy sequence where every value is equal to combine called on the previous
  /// element, and the current element.
  /// ```swift
  /// lazy([1, 2, 3]).scan(+)
  ///
  /// 3, 6
  /// ```
  @warn_unused_result
  func scan(combine: (accumulator: Generator.Element, element: Generator.Element) -> Generator.Element)
    -> LazyScan1Seq<Self> {
    return LazyScan1Seq(seq: self, combine: combine)
  }
}
