// MARK: - Eager

// MARK: Combinations

public extension RangeReplaceableCollectionType where Index : BidirectionalIndexType {
  
  /// Returns combinations without repetitions of self of length `n`
  /// - Note: Combinations are returned in lexicographical order, according to the order of `self`
  ///```swift
  ///  [1, 2, 3].combinations(2)
  ///
  ///  [1, 2], [1, 3], [2, 3]
  ///```
  
  func combinations(var n: Int) -> [[Generator.Element]] {
    guard --n >= 0 else { return [[]] }
    var combos: [[Generator.Element]] = []
    var objects = self
    while !objects.isEmpty {
      let element = objects.removeAtIndex(objects.startIndex)
      combos.extend(objects.combinations(n).map{ [element] + $0 })
    }
    return combos
  }
}

public extension CollectionType {
  
  /// Returns combinations without repetitions of self of length `n`
  /// - Note: Combinations are returned in lexicographical order, according to the order of `self`
  ///```swift
  ///  [1, 2, 3].combinations(2)
  ///
  ///  [1, 2], [1, 3], [2, 3]
  ///```
  
  func combinations(n: Int) -> [[Generator.Element]] {
    return Array(self).combinations(n)
  }
}

// MARK: Combinations with Repetition

public extension RangeReplaceableCollectionType {
  
  /// Returns combinations with repetitions of self of length `n`
  /// - Note: Combinations are returned in lexicographical order, according to the order of `self`
  ///```swift
  ///  [1, 2, 3].combinationsWithRep(2)
  ///
  ///  [1, 1], [1, 2], [1, 3], [2, 2], [2, 3], [3, 3]
  ///```
  
  func combinationsWithRep(var n: Int) -> [[Generator.Element]] {
    guard --n >= 0 else { return [[]] }
    var combos: [[Generator.Element]] = []
    var objects = self
    while let element = objects.first {
      combos.extend(objects.combinationsWithRep(n).map{ [element] + $0 })
      objects.removeAtIndex(objects.startIndex)
    }
    return combos
  }
}

public extension CollectionType {
  
  /// Returns combinations with repetitions of self of length `n`
  /// - Note: Combinations are returned in lexicographical order, according to the order of `self`
  ///```swift
  ///  [1, 2, 3].combinationsWithRep(2)
  ///
  ///  [1, 1], [1, 2], [1, 3], [2, 2], [2, 3], [3, 3]
  ///```
  
  func combinationsWithRep(n: Int) -> [[Generator.Element]] {
    return Array(self).combinationsWithRep(n)
  }
}

// MARK: - Lazy

// MARK: Combinations

public struct ComboGen<C : MutableCollectionType> : GeneratorType {
  
  private let coll: C
  private var curr: [C.Generator.Element]
  
  private var inds: [C.Index]
  
  mutating public func next() -> [C.Generator.Element]? {
    for (max, curInd) in zip(lazy(coll.indices).reverse(), inds.indices.reverse())
      where max != inds[curInd] {
      curr[curInd] = coll[++inds[curInd]]
      for j in (curInd+1)..<inds.count {
        inds[j] = inds[j-1].successor()
        curr[j] = coll[inds[j]]
      }
      return curr
    }
    return nil
  }
}

public struct ComboSeq<C : MutableCollectionType> : LazySequenceType {
  
  private let start: [C.Generator.Element]
  private let inds : [C.Index]
  private let col  : C
  
  public func generate() -> ComboGen<C> {
    return ComboGen(coll: col, curr: start, inds: inds)
  }
  
  private init(n: Int, col: C) {
    self.col = col
    var i = col.startIndex
    self.start = (0..<n).map{ (_: Int) in col[i++] }
    i = col.startIndex
    var inds = (1..<n).map{ (_: Int) in i++ }
    inds += [inds.last!]
    self.inds = inds
  }
}

public extension MutableCollectionType {
  
  /// Returns lazily-generated combinations without repetitions of self of length `n`
  /// - Note: Combinations are returned in lexicographical order, according to the order of `self`
  ///```swift
  ///  [1, 2, 3].combinations(2)
  ///
  ///  [1, 2], [1, 3], [2, 3]
  ///```
  
  func lazyCombinations(n: Int) -> ComboSeq<Self> {
    return ComboSeq(n: n, col: self)
  }
}

public extension CollectionType {
  
  /// Returns lazily-generated combinations without repetitions of self of length `n`
  /// - Note: Combinations are returned in lexicographical order, according to the order of `self`
  ///```swift
  ///  [1, 2, 3].combinations(2)
  ///
  ///  [1, 2], [1, 3], [2, 3]
  ///```
  
  func lazyCombinations(n: Int) -> ComboSeq<[Generator.Element]> {
    return ComboSeq(n: n, col: Array(self))
  }
}

// MARK: Combinations with Repetition

public struct ComboRepGen<
  C : MutableCollectionType where
  C.Index : BidirectionalIndexType
> : GeneratorType {
  
  private let coll: C
  private var curr: [C.Generator.Element]
  
  private var inds: [C.Index]
  
  private let max : C.Index
  
  mutating public func next() -> [C.Generator.Element]? {
    for curInd in inds.indices.reverse() where max != inds[curInd] {
      curr[curInd] = coll[++inds[curInd]]
      for j in (curInd+1)..<inds.count {
        inds[j] = inds[j-1]
        curr[j] = coll[inds[j]]
      }
      return curr
    }
    return nil
  }
}

public struct ComboRepSeq<
  C : MutableCollectionType where
  C.Index : BidirectionalIndexType
  > : LazySequenceType {
  
  private let start: [C.Generator.Element]
  private let inds : [C.Index]
  private let col  :  C
  private let max  :  C.Index
  
  public func generate() -> ComboRepGen<C> {
    return ComboRepGen(coll: col, curr: start, inds: inds, max: max)
  }
  
  private init(n: Int, col: C) {
    self.col = col
    self.start = Array(Repeat(count: n, repeatedValue: col.first!))
    var inds = Array(Repeat(count: n, repeatedValue: col.startIndex))
    --inds[n-1]
    self.inds = inds
    self.max = col.endIndex.predecessor()
  }
}



public extension MutableCollectionType where Self.Index : BidirectionalIndexType {
  
  /// Returns lazily-generated combinations with repetitions of self of length `n`
  /// - Note: Combinations are returned in lexicographical order, according to the order of `self`
  ///```swift
  ///  [1, 2, 3].combinationsWithRep(2)
  ///
  ///  [1, 1], [1, 2], [1, 3], [2, 2], [2, 3], [3, 3]
  ///```
  
  func lazyCombinationsWithRep(n: Int) -> ComboRepSeq<Self> {
    return ComboRepSeq(n: n, col: self)
  }
}

public extension CollectionType {
  
  /// Returns lazily-generated combinations with repetitions of self of length `n`
  /// - Note: Combinations are returned in lexicographical order, according to the order of `self`
  ///```swift
  ///  [1, 2, 3].combinationsWithRep(2)
  ///
  ///  [1, 1], [1, 2], [1, 3], [2, 2], [2, 3], [3, 3]
  ///```
  
  func lazyCombinationsWithRep(n: Int) -> ComboRepSeq<[Generator.Element]> {
    return ComboRepSeq(n: n, col: Array(self))
  }
}