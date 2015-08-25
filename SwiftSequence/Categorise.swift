// MARK: - Eager

// MARK: Categorise

public extension SequenceType {
  
  /// Categorises elements of self into a dictionary, with the keys given by keyFunc
  
  func categorise<U : Hashable>(@noescape keyFunc: Generator.Element throws -> U) rethrows -> [U:[Generator.Element]] {
    var dict: [U:[Generator.Element]] = [:]
    for el in self {
      let key = try keyFunc(el)
      dict[key]?.append(el) ?? {dict[key] = [el]}()
    }
    return dict
  }
}

public extension SequenceType where Generator.Element : Hashable {
  
  // MARK: Frequencies
  
  /// Returns a dictionary where the keys are the elements of self, and the values
  /// are their respective frequencies
  
  func freqs() -> [Generator.Element:Int] {
    var freqs: [Generator.Element:Int] = [:]
    for el in self {freqs[el]?._successorInPlace() ?? {freqs[el] = 1}()}
    return freqs
  }
  
  // MARK: Uniques
  
  /// Returns an array of self with duplicates removed
  
  public func uniques() -> [Generator.Element] {
    var prevs: Set<Generator.Element> = []
    return filter { el in
      if prevs.contains(el) { return false }
      prevs.insert(el)
      return true
    }
  }
  
  /// Returns the element which occurs most frequently in `self`
  
  public func mostFrequent() -> Generator.Element? {
    
    var freqs: [Generator.Element:Int] = [:]
    
    return reduce(nil) { (b: (Generator.Element, Int)?, e) in
      let c = (freqs[e]?.successor() ?? 1)
      freqs[e] = c
      return c > b?.1 ? (e, c) : b
    }?.0
  }
}

// MARK: - Lazy

// MARK: Uniques

public struct UniquesGen<G : GeneratorType where G.Element : Hashable> : GeneratorType {
  
  private var prevs: Set<G.Element>
  private var g: G
  
  public mutating func next() -> G.Element? {
    while let next = g.next() {
      if !prevs.contains(next) {
        prevs.insert(next)
        return next
      }
    }
    return nil
  }
}

public struct UniquesSeq<
  S : SequenceType where
  S.Generator.Element : Hashable
  > : LazySequenceType {
  private let seq: S
  public func generate() -> UniquesGen<S.Generator> {
    return UniquesGen(prevs: [], g: seq.generate())
  }
}

public extension LazySequenceType where Generator.Element : Hashable {
  
  /// returns a lazy sequence of self with duplicates removed
  
  func uniques() -> UniquesSeq<Self> {
    return UniquesSeq(seq: self)
  }
}

// MARK: Grouping

/// :nodoc:

public struct GroupByGen<G : GeneratorType> : GeneratorType {
  
  private var genr: G
  private var last: G.Element?
  private let isEq: (G.Element, G.Element) -> Bool
  
  mutating public func next() -> [G.Element]? {
    return last.map { comp in
      var group = [comp]
      last = nil
      while let next = genr.next() {
        guard isEq(comp, next) else {
          last = next
          return group
        }
        group.append(next)
      }
      return group
    }
  }
  
  private init(var g : G, isEquivalent: (G.Element, G.Element) -> Bool) {
    last = g.next()
    genr = g
    isEq = isEquivalent
  }
}

/// :nodoc:

public struct GroupBySeq<S : SequenceType> : LazySequenceType {
  private let seq: S
  private let isEquivalent: (S.Generator.Element, S.Generator.Element) -> Bool
  public func generate() -> GroupByGen<S.Generator> {
    return GroupByGen(g: seq.generate(), isEquivalent: isEquivalent)
  }
}

public extension LazySequenceType where Generator.Element : Equatable {
  
  /// Returns a lazy sequence of self, chunked into arrays of adjacent equal values
  /// ``` swift
  ///   lazy([1, 2, 2, 3, 1, 1, 3, 4, 2]).group()
  ///
  ///   [1], [2, 2], [3], [1, 1], [3], [4], [2]
  /// ```
  
  func group() -> GroupBySeq<Self> {
    return GroupBySeq(seq: self, isEquivalent: ==)
  }
}

public extension LazySequenceType {
  
  /// Returns a lazy sequence of self, chunked into arrays of adjacent equal values
  /// - Parameter isEquivalent: a function that returns true if its two parameters are equal
  ///  ```
  ///  lazy([1, 3, 5, 20, 22, 18, 6, 7]).groupBy { abs($0 - $1) < 5 }
  ///
  ///  [1, 3, 5], [20, 22, 18], [6, 7]
  /// ```
  
  func group(isEquivalent: (Generator.Element, Generator.Element) -> Bool)
    -> GroupBySeq<Self> {
      return GroupBySeq(seq: self, isEquivalent: isEquivalent)
  }
}
