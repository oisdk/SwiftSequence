// MARK: - Eager

// MARK: prefixWhile

public extension SequenceType {
  
  /// Returns an array of self up until the first element that returns false for condition
  /// ```swift
  /// [1, 2, 3, 4, 5, 2].prefixWhile { $0 < 4 }
  ///
  /// [1, 2, 3]
  /// ```
  
  func prefixWhile(@noescape condition: Generator.Element -> Bool) -> [Generator.Element] {
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
  
  func prefixWhile(condition: Generator.Element -> Bool) -> WhileSeq<Self> {
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
