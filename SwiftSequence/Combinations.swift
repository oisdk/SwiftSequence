// MARK: - Eager

// MARK: Combinations

public extension RangeReplaceableCollectionType where
  Index : BidirectionalIndexType,
  SubSequence : RangeReplaceableCollectionType,
  SubSequence.Index == Index,
  SubSequence.Generator.Element == Generator.Element {
  
  /// Returns combinations without repetitions of self of length `n`
  /// - Note: Combinations are returned in lexicographical order, according to the order of `self`
  ///```swift
  ///  [1, 2, 3].combinations(2)
  ///
  ///  [1, 2], [1, 3], [2, 3]
  ///```
  
  func combinations(var n: Int) -> [[Generator.Element]] {
    guard --n >= 0 else { return [[]] }
    return indices.flatMap {
      ind -> [[Generator.Element]] in
      let element: Generator.Element = self[ind]
      return self[ind.successor()..<endIndex]
        .combinations(n)
        .map { [element] + $0 }
    }
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

public extension RangeReplaceableCollectionType where
  Index : BidirectionalIndexType,
  SubSequence : RangeReplaceableCollectionType,
  SubSequence.Index == Index,
  SubSequence.Generator.Element == Generator.Element  {
  /// Returns combinations with repetitions of self of length `n`
  /// - Note: Combinations are returned in lexicographical order, according to the order of `self`
  ///```swift
  ///  [1, 2, 3].combinationsWithRep(2)
  ///
  ///  [1, 1], [1, 2], [1, 3], [2, 2], [2, 3], [3, 3]
  ///```
  
  func combinationsWithRep(var n: Int) -> [[Generator.Element]] {
    guard --n >= 0 else { return [[]] }
    return indices.flatMap {
      ind -> [[Generator.Element]] in
      let element: Generator.Element = self[ind]
      return self[ind..<endIndex]
        .combinationsWithRep(n)
        .map {
          (rest: [Generator.Element]) -> [Generator.Element] in
          [element] + rest
      }
    }
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
    guard inds.count > 1 else {
      if inds.isEmpty {
        inds = [coll.endIndex]
        return []
      }
      return { $0 == coll.endIndex ? nil : [coll[$0]] } (inds[0]++)
    }
    for (max, curInd) in zip(coll.indices.reverse(), inds.indices.reverse())
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
    guard n != 0 else {self.inds = []; return}
    var inds = (1..<n).map{ (_: Int) in i++ }
    inds.append(inds.last ?? col.startIndex)
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