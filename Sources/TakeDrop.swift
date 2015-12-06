// MARK: - Eager

// MARK: prefixWhile

public extension SequenceType {
  
  /// Returns an array of self up until the first element that returns false for condition
  /// ```swift
  /// [1, 2, 3, 4, 5, 2].prefixWhile { $0 < 4 }
  ///
  /// [1, 2, 3]
  /// ```
  @warn_unused_result
  func prefixWhile(@noescape condition: Generator.Element throws -> Bool) rethrows -> [Generator.Element] {
    var ret : [Generator.Element] = []
    var g = generate()
    while let next = g.next() where try condition(next) { ret.append(next) }
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
  @warn_unused_result
  func dropWhile(@noescape condition: Generator.Element throws -> Bool) rethrows -> [Generator.Element] {
    var g = generate()
    while let next = g.next() {
      if try !condition(next) {
        return [next] + GeneratorSequence(g)
      }
    }
    return []
  }
}

public extension SequenceType {
  /**
  Returns a tuple of the prefix and suffix of `self`, the first element
  being the prefix up to `n`.
  */
  public func breakAt(n: Int) -> ([Generator.Element],[Generator.Element]) {
    let r = max(0, underestimateCount() - n)
    var f,b : [Generator.Element]
    (f,b) = ([],[])
    f.reserveCapacity(n)
    b.reserveCapacity(r)
    var g = generate()
    for _ in 0..<n {
      if let e = g.next() { f.append(e) } else { return (f,b) }
    }
    while let e = g.next() { b.append(e) }
    return (f,b)
  }
}

public extension CollectionType {
  /**
  Returns a tuple of the prefix and suffix of `self`, the first element
  being the prefix up to `n`.
  */
  public func breakAt(n: Index) -> (SubSequence, SubSequence) {
    return (prefixUpTo(n),suffixFrom(n))
  }
}

public extension CollectionType where Index == Int {
  /**
  Returns a tuple of the prefix and suffix of `self`, the first element
  being the prefix up to `n`.
  */
  public func breakAt(n: Int) -> (SubSequence, SubSequence) {
    return (prefixUpTo(n),suffixFrom(n))
  }
}
public extension SequenceType {
  /**
  Returns a tuple of the prefix and suffix of `self`, the first element
  being the prefix up to the first elements of `self` which returns
  `true` for `isBreak`.
  */
  public func breakAt(@noescape isBreak: Generator.Element throws -> Bool)
    rethrows -> ([Generator.Element],[Generator.Element]) {
    var f,b : [Generator.Element]
    (f,b) = ([],[])
    var g = generate()
    while let e = g.next() {
      if try isBreak(e) {
        b.append(e)
        while let be = g.next() { b.append(be) }
        return (f,b)
      } else {
        f.append(e)
      }
    }
    return (f,b)
  }
}
public extension CollectionType {
  /**
  Returns a tuple of the prefix and suffix of `self`, the first element
  being the prefix up to the first elements of `self` which returns
  `true` for `isBreak`.
  */
  public func breakAt(@noescape isBreak: Generator.Element throws -> Bool) rethrows -> (SubSequence, SubSequence) {
    return try indexOf(isBreak).map(breakAt) ?? (suffixFrom(startIndex),prefixUpTo(startIndex))
  }
}
// MARK: - Lazy

// MARK: TakeWhile
/// :nodoc:
public struct WhileGen<G : GeneratorType> : GeneratorType {
  
  private var g: G
  private let condition : G.Element -> Bool
  /// :nodoc:
  mutating public func next() -> G.Element? {
    if let next = g.next() where condition(next) {
      return next
    }
    return nil
  }
}
/// :nodoc:
public struct WhileSeq<S : SequenceType> : LazySequenceType {
  
  private let seq: S
  private let condition: S.Generator.Element -> Bool
  /// :nodoc:
  public func generate() -> WhileGen<S.Generator> {
    return WhileGen(g: seq.generate(), condition: condition)
  }
}

public extension LazySequenceType {
  
  /// Returns a lazy sequence of self up until the first element that returns false for
  /// condition
  /// ```swift
  /// [1, 2, 3, 4, 5, 2].lazy.takeWhile { $0 < 4 }
  ///
  /// 1, 2, 3
  /// ```
  @warn_unused_result
  func prefixWhile(condition: Generator.Element -> Bool) -> WhileSeq<Self> {
    return WhileSeq(seq: self, condition: condition)
  }
}

// MARK: DropWhile
/// :nodoc:
public struct DropWhileGen<G : GeneratorType> : GeneratorType {
  
  private let predicate: G.Element -> Bool
  private var nG: G?
  private var oG: G
  
  private init(g: G, predicate: G.Element -> Bool) {
    nG = nil
    oG = g
    self.predicate = predicate
  }
  /// :nodoc:
  public mutating func next() -> G.Element? {
    guard nG == nil else { return nG!.next() }
    while let next = oG.next() {
      if !predicate(next) {
        nG = oG
        return next
      }
    }
    return nil
  }
}
/// :nodoc:
public struct DropWhileSeq<S : SequenceType> : LazySequenceType {
  
  private let predicate: S.Generator.Element -> Bool
  private let seq: S
  /// :nodoc:
  public func generate() -> DropWhileGen<S.Generator> {
    return DropWhileGen(g: seq.generate(), predicate: predicate)
  }
}

public extension LazySequenceType {
  
  /// Returns a lazy sequence of self with the first elements that return true for
  /// condition dropped
  /// ```swift
  /// [1, 2, 3, 4, 5, 2].lazy.dropWhile { $0 < 4 }
  ///
  /// 4, 5, 2
  /// ```
  @warn_unused_result
  func dropWhile(predicate: Generator.Element -> Bool) -> DropWhileSeq<Self> {
    return DropWhileSeq(predicate: predicate, seq: self)
  }
}
