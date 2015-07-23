// MARK: - Eager

// MARK: Take

public extension SequenceType {
  
  /// Returns an array of the first n elements of self
  
  func take(var n: Int) -> [Generator.Element] {
    var g = generate()
    var ret: [Generator.Element] = []
    while --n >= 0, let next = g.next() { ret.append(next) }
    return ret
  }
}

// MARK: Drop

public extension SequenceType {
  
  /// Returns an array of self with the first n elements dropped
  
  func drop(n: Int) -> [Generator.Element] {
    var g = generate()
    for _ in 0..<n { guard let _ = g.next() else { return [] } }
    return Array(GeneratorSequence(g))

  }
}

// MARK: TakeWhile

public extension SequenceType {
  
  /// Returns an array of self up until the first element that returns false for condition
  /// ```swift
  /// [1, 2, 3, 4, 5, 2].takeWhile { $0 < 4 }
  ///
  /// [1, 2, 3]
  /// ```
  
  func takeWhile(@noescape condition: Generator.Element -> Bool) -> [Generator.Element] {
    var ret : [Generator.Element] = []
    var g = generate()
    while let next = g.next() where condition(next) { ret.append(next) }
    return ret
  }
}

// MARK: DropWhile

public extension SequenceType {
  
  /// Returns an array of self with the first elements that return true for condition
  /// dropped
  /// ```swift
  /// [1, 2, 3, 4, 5, 2].dropWhile { $0 < 4 }
  ///
  /// [4, 5, 2]
  /// ```
  
  func dropWhile(@noescape condition: Generator.Element -> Bool) -> [Generator.Element] {
    var g = generate()
    while let next = g.next() {
      if !condition(next) {
        return [next] + GeneratorSequence(g)
      }
    }
    return []
  }
}

// MARK: - Lazy

// MARK: Take

public struct TakeGen<G : GeneratorType> : GeneratorType {
  
  private var g: G
  private var n: Int
  
  mutating public func next() -> G.Element? {
    return --n < 0 ? nil : g.next()
  }
  
  private init(g: G, n: Int) {
    self.g = g
    self.n = n
  }
}

public struct TakeSeq<S : SequenceType> : LazySequenceType {
  
  private let seq: S
  private let n: Int
  
  public func generate() -> TakeGen<S.Generator> {
    return TakeGen(g: seq.generate(), n: n)
  }
}

public extension LazySequenceType {
  
  /// Returns a lazy sequence of the first n elements of self
  
  func take(n: Int) -> TakeSeq<Self> {
    return TakeSeq(seq: self, n: n)
  }
}

// MARK: Drop

public struct DropSeq<S : SequenceType> : LazySequenceType {
  
  private let seq: S
  private let n: Int
  
  public func generate() -> S.Generator {
    var g = seq.generate()
    for _ in 0..<n { guard let _ = g.next() else {
      g = seq.generate()
      for _ in 0..<(n - 1) { g.next() }
      return g
      }
    }
    return g
  }
}

public extension LazySequenceType {
  
  /// Returns a lazy sequence of self with the first n elements dropped
  
  func drop(n: Int) -> DropSeq<Self> {
    return DropSeq(seq: self, n: n)
  }
}

// MARK: TakeWhile

public struct WhileGen<G : GeneratorType> : GeneratorType {
  
  private var g: G
  private let condition : G.Element -> Bool
  
  mutating public func next() -> G.Element? {
    return g.next().flatMap {
      condition($0) ? $0 : nil
    }
  }
}

public struct WhileSeq<S : SequenceType> : LazySequenceType {
  
  private let seq: S
  private let condition: S.Generator.Element -> Bool
  
  public func generate() -> WhileGen<S.Generator> {
    return WhileGen(g: seq.generate(), condition: condition)
  }
}

public extension LazySequenceType {
  
  /// Returns a lazy sequence of self up until the first element that returns false for
  /// condition
  /// ```swift
  /// lazy([1, 2, 3, 4, 5, 2]).takeWhile { $0 < 4 }
  ///
  /// 1, 2, 3
  /// ```
  
  func takeWhile(condition: Generator.Element -> Bool) -> WhileSeq<Self> {
    return WhileSeq(seq: self, condition: condition)
  }
}

// MARK: DropWhile

public struct DropWhileGen<G : GeneratorType> : GeneratorType {
  
  private let predicate: G.Element -> Bool
  private var nG: G!
  private var oG: G
  
  init(g: G, predicate: G.Element -> Bool) {
    nG = nil
    oG = g
    self.predicate = predicate
  }
  
  public mutating func next() -> G.Element? {
    guard nG == nil else { return nG.next() }
    while let next = oG.next() {
      if !predicate(next) {
        nG = oG
        return next
      }
    }
    return nil
  }
}

public struct DropWhileSeq<S : SequenceType> : LazySequenceType {
  
  private let predicate: S.Generator.Element -> Bool
  private let seq: S
  
  public func generate() -> DropWhileGen<S.Generator> {
    return DropWhileGen(g: seq.generate(), predicate: predicate)
  }
}

public extension LazySequenceType {
  
  /// Returns a lazy sequence of self with the first elements that return true for
  /// condition dropped
  /// ```swift
  /// lazy([1, 2, 3, 4, 5, 2]).dropWhile { $0 < 4 }
  ///
  /// 4, 5, 2
  /// ```
  
  func dropWhile(predicate: Generator.Element -> Bool) -> DropWhileSeq<Self> {
    return DropWhileSeq(predicate: predicate, seq: self)
  }
}

// MARK: List

public extension List {
  public func take(n: Int) -> List<Element> {
    switch (n, self) {
    case (0, _), (_, .Nil): return .Nil
    case (_, let .Cons(head, tail)): return head |> tail.take(n - 1)
    }
  }
  public func drop(n: Int) -> List<Element> {
    switch (n, self) {
    case (0, _), (_, .Nil): return self
    case (_, .Cons(_, let tail)): return tail.drop(n - 1)
    }
  }
  public func takeWhile(@noescape condition: Element -> Bool) -> List<Element> {
    switch self {
    case .Nil: return self
    case let .Cons(head, tail):
      return condition(head) ? (head |> tail.takeWhile(condition)) : .Nil
    }
  }
  public func dropWhile(@noescape condition: Element -> Bool) -> List<Element> {
    switch self {
    case .Nil: return self
    case let .Cons(head, tail):
      return condition(head) ? tail.dropWhile(condition) : (head |> tail)
    }
  }
}

public extension LazyList {
  public func take(n: Int) -> LazyList<Element> {
    switch (n, self) {
    case (0, _), (_, .Nil): return .Nil
    case (_, let .Cons(head, tail)): return head |> tail().take(n - 1)
    }
  }
  public func drop(n: Int) -> LazyList<Element> {
    switch (n, self) {
    case (0, _), (_, .Nil): return self
    case (_, .Cons(_, let tail)): return tail().drop(n - 1)
    }
  }
  public func takeWhile(condition: Element -> Bool) -> LazyList<Element> {
    switch self {
    case .Nil: return self
    case let .Cons(head, tail):
      return condition(head) ? (head |> tail().takeWhile(condition)) : .Nil
    }
  }
  public func dropWhile(@noescape condition: Element -> Bool) -> LazyList<Element> {
    switch self {
    case .Nil: return self
    case let .Cons(head, tail):
      return condition(head) ? tail().dropWhile(condition) : (head |> tail)
    }
  }
}