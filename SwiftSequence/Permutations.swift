// MARK: - Common

public extension MutableCollectionType where Generator.Element : Comparable {
  
  /// [Algorithm](https://en.wikipedia.org/wiki/Permutation#Generation_in_lexicographic_order)
  
  mutating func nextLexPerm() -> Self? {
    for k in dropFirst(indices.reverse()) where self[k] < self[k.successor()] {
      for l in indices.reverse() where self[k] < self[l] {
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

public extension MutableCollectionType {
  
  /// [Algorithm](https://en.wikipedia.org/wiki/Permutation#Generation_in_lexicographic_order)
  
  mutating func nextLexPerm
    (isOrderedBefore: (Generator.Element, Generator.Element) -> Bool) -> Self? {
      for k in dropFirst(indices.reverse())
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

public struct LexPermGen<
  C : MutableCollectionType where
  C.Generator.Element : Comparable
  > : GeneratorType  {
    private var col: C?
    mutating public func next() -> C? {
      defer{ col = col?.nextLexPerm() }
      return col
    }
}

public struct LexPermGenCustom<C : MutableCollectionType> : GeneratorType  {
  private var col: C?
  private let order: (C.Generator.Element, C.Generator.Element) -> Bool
  mutating public func next() -> C? {
    defer{ col = col?.nextLexPerm(order) }
    return col
  }
}

public struct LexPermSeq<
  C : MutableCollectionType where
  C.Generator.Element : Comparable
  > : LazySequenceType {
  private let col: C
  public func generate() -> LexPermGen<C> { return LexPermGen(col: col) }
}

public struct LexPermSeqCustom<C : MutableCollectionType> : LazySequenceType {
  private let col: C
  private let order: (C.Generator.Element, C.Generator.Element) -> Bool
  public func generate() -> LexPermGenCustom<C> {
    return LexPermGenCustom(col: col, order: order)
  }
}

// MARK: - Eager

public extension MutableCollectionType {
  
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
  
  func lexPermutations
    (isOrderedBefore: (Generator.Element, Generator.Element) -> Bool) -> [Self]{
      return LexPermSeqCustom(col: self, order: isOrderedBefore).array()
  }
}

public extension CollectionType where
  Self : MutableCollectionType,
  Generator.Element : Comparable {
  
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
  
    func lexPermutations() -> [Self] { return LexPermSeq(col: self).array() }
}

public extension CollectionType where Index : Comparable {
  
  /// Returns an array of the permutations of self.
  /// - Note: The permutations are lexicographically ordered, based on the indices of self
  /// ```swift
  /// [1, 2, 3].permutations()
  /// 
  /// [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
  /// ```
  
  func permutations() -> [[Generator.Element]] {
    return LexPermSeq(col: Array(indices)).map { inds in inds.map{self[$0]} }.array()
  }
}

// MARK: - Lazy

public extension MutableCollectionType {
  
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
  
  func lazyLexPermutations(isOrderedBefore: (Generator.Element, Generator.Element) -> Bool)
    -> LexPermSeqCustom<Self> {
      return LexPermSeqCustom(col: self, order: isOrderedBefore)
  }
}

public extension MutableCollectionType where Generator.Element : Comparable {
  
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
  
    func lazyLexPermutations() -> LexPermSeq<Self> { return LexPermSeq(col: self) }
}

public extension CollectionType where Index : Comparable {
  
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
  
  func lazyPermutations()
    -> LazySequence<MapSequence<LexPermSeq<Array<Index>>, [Generator.Element]>> {
      return LexPermSeq(col: Array(indices)).map { inds in inds.map{self[$0]} }
  }
}
