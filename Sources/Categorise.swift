// MARK: - Eager

// MARK: Categorise

public extension SequenceType {
  
  /**
  Categorises elements of `self` into a dictionary, with the keys
  given by `keyFunc`
  ```swift
  struct Person : CustomStringConvertible {
    let name: String
    let age : Int
    init(_ name: String, _ age: Int) {
      self.name = name
      self.age  = age
    }
    var description: String { return name }
  }
  
  let people = [ 
    Person("Jo", 20),
    Person("An", 20),
    Person("Cthulu", 4000)
  ]
  
  people.categorise { p in p.age }
  
  //[20: [Jo, An], 4000: [Cthulu]]
  ```
  */
  @warn_unused_result
  func categorise<U : Hashable>(@noescape keyFunc: Generator.Element throws -> U)
    rethrows -> [U:[Generator.Element]] {
    var dict: [U:[Generator.Element]] = [:]
    for el in self {
      let key = try keyFunc(el)
      if case nil = dict[key]?.append(el) { dict[key] = [el] }
    }
    return dict
  }
}

public extension SequenceType where Generator.Element : Hashable {
  
  // MARK: Frequencies
  
  /** 
  Returns a dictionary where the keys are the elements of self, and
  the values are their respective frequencies 
  ```swift
  [0, 3, 0, 1, 1, 3, 2, 3, 1, 0].freqs()
  // [2: 1, 0: 3, 3: 3, 1: 3]
  ```
  */
  @warn_unused_result
  func freqs() -> [Generator.Element:Int] {
    var freqs: [Generator.Element:Int] = [:]
    for el in self { freqs[el] = freqs[el]?.successor() ?? 1 }
    return freqs
  }
  
  // MARK: Uniques
  
  /** 
  Returns an array of the elements of `self`, in order, with
  duplicates removed
  ```swift
  [3, 1, 2, 3, 2, 1, 1, 2, 3, 3].uniques()
  // [3, 1, 2]
  ```
  */
  @warn_unused_result
  public func uniques() -> [Generator.Element] {
    var prevs: Set<Generator.Element> = []
    var uniqs: [Generator.Element] = []
    for el in self where !prevs.contains(el) {
      prevs.insert(el)
      uniqs.append(el)
    }
    return uniqs
  }
  
  /// Returns the element which occurs most frequently in `self`
  @warn_unused_result
  public func mostFrequent() -> Generator.Element? {
    var g = generate()
    guard let b = g.next() else { return nil }
    var be = b
    var bn = 1
    var freqs: [Generator.Element:Int] = [:]
    for e in self {
      let n = (freqs[e] ?? 0) + 1
      if n > bn { (be,bn) = (e,n) }
      freqs[e] = n
    }
    return be
  }
}

// MARK: - Lazy

// MARK: Uniques
/// :nodoc:
public struct UniquesGen<G : GeneratorType where G.Element : Hashable> : GeneratorType {
  
  private var prevs: Set<G.Element>
  private var g: G
  /// :nodoc:
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
/// :nodoc:
public struct UniquesSeq<
  S : SequenceType where
  S.Generator.Element : Hashable
  > : LazySequenceType {
  private let seq: S
  /// :nodoc:
  public func generate() -> UniquesGen<S.Generator> {
    return UniquesGen(prevs: [], g: seq.generate())
  }
}

public extension LazySequenceType where Generator.Element : Hashable {
  
  /// returns a `LazySequence` of the elements of `self`, in order, with
  /// duplicates removed
  @warn_unused_result
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
  /// :nodoc:
  mutating public func next() -> [G.Element]? {
    guard let head = last else { return nil }
    var group = [head]
    last = nil
    while let next = genr.next() {
      guard isEq(group.last!, next) else {
        last = next
        return group
      }
      group.append(next)
    }
    return group
  }
  private init(g : G, isEquivalent: (G.Element, G.Element) -> Bool) {
    genr = g
    last = genr.next()
    isEq = isEquivalent
  }
}

/// :nodoc:

public struct GroupBySeq<S : SequenceType> : LazySequenceType {
  private let seq: S
  private let isEquivalent: (S.Generator.Element, S.Generator.Element) -> Bool
  /// :nodoc:
  public func generate() -> GroupByGen<S.Generator> {
    return GroupByGen(g: seq.generate(), isEquivalent: isEquivalent)
  }
}

public extension LazySequenceType where Generator.Element : Equatable {
  
  /// Returns a lazy sequence of self, chunked into arrays of adjacent equal values
  /// ```swift
  /// [1, 2, 2, 3, 1, 1, 3, 4, 2].lazy.group()
  ///
  /// [1], [2, 2], [3], [1, 1], [3], [4], [2]
  /// ```
  @warn_unused_result
  func group() -> GroupBySeq<Self> {
    return GroupBySeq(seq: self, isEquivalent: ==)
  }
}

public extension LazySequenceType {
  
  /// Returns a lazy sequence of self, chunked into arrays of adjacent equal values
  /// - Parameter isEquivalent: a function that returns true if its two parameters are equal
  /// ```swift
  /// [1, 3, 5, 20, 22, 18, 6, 7].lazy.groupBy { (a,b) in abs(a - b) < 5 }
  ///
  /// [1, 3, 5], [20, 22, 18], [6, 7]
  /// ```
  @warn_unused_result
  func group(isEquivalent: (Generator.Element, Generator.Element) -> Bool)
    -> GroupBySeq<Self> {
      return GroupBySeq(seq: self, isEquivalent: isEquivalent)
  }
}
