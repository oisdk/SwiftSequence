// MARK: - Common

public extension MutableCollectionType {
  
  /// [Algorithm](https://en.wikipedia.org/wiki/Permutation#Generation_in_lexicographic_order)

  public mutating func nextLexPerm
    (isOrderedBefore: (Generator.Element, Generator.Element) -> Bool) -> Self? {
      for k in indices.reverse().dropFirst()
        where isOrderedBefore(self[k], self[k.successor()]) {
          for l in indices.reverse() where isOrderedBefore(self[k], self[l]) {
            swap(&self[k], &self[l])
            let r = (k.successor()..<endIndex)
            for (x, y) in zip(r, r.reverse()) {
              if x == y || x == y.successor() { return self }
              swap(&self[x], &self[y])
            }
          }
      }
      return nil
  }
}

public extension MutableCollectionType where Generator.Element : Comparable {
  
  /// [Algorithm](https://en.wikipedia.org/wiki/Permutation#Generation_in_lexicographic_order)
  
  public mutating func nextLexPerm() -> Self? {
    return nextLexPerm(<)
  }
}
/// :nodoc:
public struct LexPermGen<C : MutableCollectionType> : GeneratorType  {
  private var col: C?
  private let order: (C.Generator.Element, C.Generator.Element) -> Bool
  /// :nodoc:
  mutating public func next() -> C? {
    defer { col = col?.nextLexPerm(order) }
    return col
  }
}
/// :nodoc:
public struct LexPermSeq<C : MutableCollectionType> : LazySequenceType {
  private let col: C
  private let order: (C.Generator.Element, C.Generator.Element) -> Bool
  /// :nodoc:
  public func generate() -> LexPermGen<C> {
    return LexPermGen(col: col, order: order)
  }
}

// MARK: - Eager

public extension SequenceType {
  
  /// Returns an array of the permutations of self, ordered lexicographically, according
  /// to the closure `isOrderedBefore`.
  /// - Note: The permutations returned follow self, so if self is not the first
  /// lexicographically ordered permutation, not all permutations will be returned.
  /// ```swift
  /// [1, 2, 3].lexPermutations(<)
  ///
  /// [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
  /// ```
  /// ```swift
  /// [1, 2, 3].lexPermutations(>)
  ///
  /// [[1, 2, 3]]
  /// ```
  @warn_unused_result
  public func lexPermutations
    (isOrderedBefore: (Generator.Element, Generator.Element) -> Bool) -> [[Generator.Element]] {
      return Array(LexPermSeq(col: Array(self), order: isOrderedBefore))
  }
}

public extension MutableCollectionType where Generator.Element : Comparable {
  
  /// Returns an array of the permutations of self, ordered lexicographically.
  /// - Note: The permutations returned follow self, so if self is not the first
  /// lexicographically ordered permutation, not all permutations will be returned.
  /// ```swift
  /// [1, 2, 3].lexPermutations()
  ///
  /// [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
  /// ```
  /// ```swift
  /// [3, 2, 1].lexPermutations()
  ///
  /// [[3, 2, 1]]
  /// ```
  @warn_unused_result
  public func lexPermutations() -> [[Generator.Element]] {
      return Array(LexPermSeq(col: Array(self), order: <))
  }
}

public extension SequenceType {
  
  /// Returns an array of the permutations of self.
  /// ```swift
  /// [1, 2, 3].permutations()
  /// 
  /// [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
  /// ```
  @warn_unused_result
  public func permutations() -> [[Generator.Element]] {
    var col = Array(self)
    return Array(LexPermSeq(col: Array(col.indices), order: <).map { inds in inds.map{col[$0]} })
  }
  /// Returns an array of the permutations of length `n` of self.
  /// ```swift
  /// [1, 2, 3].permutations()
  ///
  /// [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
  /// ```
  public func permutations(n: Int) -> [[Generator.Element]] {
    return Array(lazyCombos(n).flatMap { a in a.permutations() })
  }
}

// MARK: - Lazy

public extension SequenceType {
  
  /// Returns a lazy sequence of the permutations of self, ordered lexicographically,
  /// according to the closure `isOrderedBefore`.
  /// - Note: The permutations returned follow self, so if self is not the first
  /// lexicographically ordered permutation, not all permutations will be returned.
  /// ```swift
  /// lazy([1, 2, 3]).lazyLexPermutations(<)
  ///
  /// [1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]
  /// ```
  /// ```swift
  /// lazy([1, 2, 3]).lazyLexPermutations(>)
  ///
  /// [1, 2, 3]
  /// ```
  @warn_unused_result
  public func lazyLexPermutations(isOrderedBefore: (Generator.Element, Generator.Element) -> Bool)
    -> LexPermSeq<[Generator.Element]> {
      return LexPermSeq(col: Array(self), order: isOrderedBefore)
  }
}

public extension SequenceType where Generator.Element : Comparable {
  
  /// Returns a lazy sequence of the permutations of self, ordered lexicographically.
  /// - Note: The permutations returned follow self, so if self is not the first
  /// lexicographically ordered permutation, not all permutations will be returned.
  /// ```swift
  /// lazy([1, 2, 3]).lazyLexPermutations()
  ///
  /// [1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]
  /// ```
  /// ```swift
  /// lazy([3, 2, 1]).lazyLexPermutations()
  ///
  /// [3, 2, 1]
  /// ```
  @warn_unused_result
  public func lazyLexPermutations()  -> LexPermSeq<[Generator.Element]> {
      return LexPermSeq(col: Array(self), order: <)
  }
}

public extension SequenceType {
  
  /// Returns a lazy sequence of the permutations of self.
  /// - Note: The permutations are lexicographically ordered, based on the indices of self
  /// ```swift
  /// lazy([1, 2, 3]).lazyPermutations()
  ///
  /// [1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]
  /// ```
  /// ```swift
  /// lazy([3, 2, 1]).lazyPermutations()
  ///
  /// [3, 2, 1], [3, 1, 2], [2, 3, 1], [2, 1, 3], [1, 3, 2], [1, 2, 3]
  /// ```
  @warn_unused_result
  public func lazyPermutations() -> LazyMapSequence<LexPermSeq<[Int]>, [Self.Generator.Element]> {
      let col = Array(self)
      return col.indices.lazyLexPermutations().map { $0.map { col[$0] } }
  }
}
