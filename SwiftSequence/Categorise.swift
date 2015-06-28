// MARK: - Eager

// MARK: Categorise

public extension SequenceType {
  
  /// Categorises elements of self into a dictionary, with the keys given by keyFunc
  
  func categorise<U : Hashable>(keyFunc: Generator.Element -> U) -> [U:[Generator.Element]] {
    var dict: [U:[Generator.Element]] = [:]
    for el in self {
      let key = keyFunc(el)
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
  
  func uniques() -> [Generator.Element] {
    var prevs: Set<Generator.Element> = []
    return self.filter {
      el in
      defer { prevs.insert(el) }
      return !prevs.contains(el)
    }
  }
  
  // MARK: Replace
  
  /// Returns self with all of the keys in reps replaced by their values
  
  func replace(reps: [Generator.Element:Generator.Element]) -> [Generator.Element] {
    return self.map{reps[$0] ?? $0}
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

// MARK: Replace

public extension LazySequenceType where Generator.Element : Hashable {
  
  /// Returns a lzy sequence of self with all of the keys in reps replaced by their values
  
  func replace(reps: [Generator.Element:Generator.Element]) -> LazySequence<MapSequenceView<Self, Self.Generator.Element>> {
    return lazy(self).map { reps[$0] ?? $0 }
  }
  
}

// MARK: Grouping

public struct GroupGen<G : GeneratorType where G.Element : Equatable> : GeneratorType {
  
  private var g   : G
  private var last: [G.Element]?
  
  mutating public func next() -> [G.Element]? {
    while let next = g.next() {
      if next == last?[0] {
        last!.append(next)
      } else {
        defer { last = [next] }
        return  last
      }
    }
    defer { last = nil }
    return last
  }
  
  private init(var g : G) {
    self.last = g.next().map{[$0]}
    self.g = g
  }
}

public struct GroupByGen<G : GeneratorType> : GeneratorType {
  
  private var g   : G
  private var last: [G.Element]?
  private let isEquivalent: (G.Element, G.Element) -> Bool
  
  mutating public func next() -> [G.Element]? {
    while let next = g.next() {
      if let lastU = last where isEquivalent(lastU[0], next) {
        last!.append(next)
      } else {
        defer { last = [next] }
        return last
      }
    }
    defer { last = nil }
    return last
  }
  
  private init(var g : G, isEquivalent: (G.Element, G.Element) -> Bool) {
    self.last = g.next().map{[$0]}
    self.g = g
    self.isEquivalent = isEquivalent
  }
}

public struct GroupSeq<
  S : SequenceType where
  S.Generator.Element : Equatable
> : LazySequenceType {
  private let seq: S
  public func generate() -> GroupGen<S.Generator> {
    return GroupGen(g: seq.generate())
  }
}

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
  
  func group() -> GroupSeq<Self> {
    return GroupSeq(seq: self)
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
  
  func groupBy(isEquivalent: (Generator.Element, Generator.Element) -> Bool)
    -> GroupBySeq<Self> {
      return GroupBySeq(seq: self, isEquivalent: isEquivalent)
  }
}

public struct GroupByKeyGen<G : GeneratorType, K: Equatable> : GeneratorType {
  
  private var g: G
  
  private var head: K?
  private var list: [G.Element]?
  
  private let keyFunc: G.Element -> K
  
  mutating public func next() -> [G.Element]? {
    while let next = g.next() {
      if keyFunc(next) == head {
        list?.append(next)
      } else {
        defer {
          head = keyFunc(next)
          list = [next]
        }
        return list
      }
    }
    defer { list = nil }
    return list
  }
}

public struct GroupByKeySeq<S : SequenceType, K : Equatable> : LazySequenceType {
  
  private let seq: S
  private let keyFunc: S.Generator.Element -> K
  
  public func generate() -> GroupByKeyGen<S.Generator, K> {
    var g = seq.generate()
    let list = [g.next()!]
    let head = keyFunc(list[0])
    return GroupByKeyGen(g: g, head: head, list: list, keyFunc: keyFunc)
  }
}

public extension LazySequenceType {
  
  /// Returns a lazy sequence of self, chunked into arrays of adjacent equal keys
  /// - Parameter keyFunc: a function that returns the keys by which to group the elements of self
  ///  ```
  ///  lazy([1, 3, 5, 2, 4, 6, 6, 7, 1, 1]).groupBy { $0 % 2 }
  ///
  ///  [[1, 3, 5], [2, 4, 6, 6], [7, 1, 1]]
  /// ```
  
  func groupBy<T : Equatable>
    (keyFunc: (Generator.Element) -> T) -> GroupByKeySeq<Self, T> {
      return GroupByKeySeq(seq: self, keyFunc: keyFunc)
  }
}
