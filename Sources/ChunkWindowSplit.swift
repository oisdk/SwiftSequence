// MARK: - Eager

// MARK: Chunk

public extension CollectionType {
  
  /// Returns an array of arrays of n non-overlapping elements of self
  /// - Parameter n: The size of the chunk
  /// - Precondition: `n > 0`
  /// - SeeAlso: `func window(n: Int) -> [[Self.Generator.Element]]`
  ///  ```swift
  ///  [1, 2, 3, 4, 5].chunk(2)
  ///
  ///  [[1, 2], [3, 4], [5]]
  /// ```
  @warn_unused_result
  public func chunk(n: Index.Distance) -> [SubSequence] {
    var res: [SubSequence] = []
    var i = startIndex
    var j: Index
    while i != endIndex {
      j = i.advancedBy(n, limit: endIndex)
      res.append(self[i..<j])
      i = j
    }
    return res
  }
}

// MARK: Window

public extension CollectionType {
  
  /// Returns an array of arrays of n overlapping elements of self
  /// - Parameter n: The size of the window
  /// - SeeAlso: `func chunk(n: Int) -> [[Self.Generator.Element]]`
  ///  ```swift
  ///  [1, 2, 3, 4].window(2)
  ///
  ///  [[1, 2], [2, 3], [3, 4]]
  ///   ```
  @warn_unused_result
  func window(n: Index.Distance) -> [SubSequence] {
    var ret: [SubSequence] = []
    ret.reserveCapacity(underestimateCount() - numericCast(n))
    var i = startIndex
    var j = i.advancedBy(n, limit: endIndex)
    while true {
      ret.append(self[i..<j])
      i = i.successor()
      if j == endIndex { return ret }
      j = j.successor()
    }
  }
}

// MARK: - Lazy

// MARK: Chunk
/// :nodoc:
public struct ChunkGen<C: CollectionType> : GeneratorType {
  
  private var c: C
  private let n: C.Index.Distance
  private var i: C.Index
  
  public mutating func next() -> C.SubSequence? {
    if i == c.endIndex { return nil }
    let j = i.advancedBy(n, limit: c.endIndex)
    defer { i = j }
    return c[i..<j]
  }
}
/// :nodoc:
public struct ChunkSeq<C: CollectionType> : LazySequenceType {
  
  private let c: C
  private let n: C.Index.Distance
  /// :nodoc:
  public func generate() -> ChunkGen<C> {
    return ChunkGen(c: c, n: n, i: c.startIndex)
  }
}

public extension LazyCollectionType {
  
  /// Returns lazily-generated arrays of n non-overlapping elements of self
  /// - Parameter n: The size of the chunk
  /// - SeeAlso: `func window(n: Int) -> WindowSeq<Self>`
  ///  ```swift
  ///  lazy([1, 2, 3, 4, 5]).chunk(2)
  ///
  ///  [1, 2], [3, 4], [5]
  /// ```
  @warn_unused_result
  func chunk(n: Index.Distance) -> ChunkSeq<Self> {
    return ChunkSeq(c: self, n: n)
  }
}

// MARK: Window
/// :nodoc:
public struct WindowGen<C: CollectionType> : GeneratorType {
  
  private let c: C
  private var i, j: C.Index
  private var s: Bool
  /// :nodoc:
  mutating public func next() -> C.SubSequence? {
    if s { return nil }
    if j == c.endIndex {
      s = true
      return c[i..<j]
    }
    defer { (i,j) = (i.successor(),j.successor()) }
    return c[i..<j]
  }
}

/// :nodoc:

public struct WindowSeq<C: CollectionType> : LazySequenceType {
  
  private let c: C
  private let n: C.Index.Distance
  /// :nodoc:
  public func generate() -> WindowGen<C> {
    return WindowGen(c: c, i: c.startIndex, j: c.startIndex.advancedBy(n, limit: c.endIndex), s: false)
  }
}

public extension LazyCollectionType {
  
  /// Returns lazily-generated arrays of n overlapping elements of self
  /// - Parameter n: The size of the window
  /// - SeeAlso: `func chunk(n: Int) -> ChunkSeq<Self>`
  ///  ```swift
  ///  lazy([1, 2, 3, 4]).window(2)
  ///
  ///  [1, 2], [2, 3], [3, 4]
  ///   ```
  @warn_unused_result
  func window(n: Index.Distance) -> WindowSeq<Self> {
    return WindowSeq(c: self, n: n)
  }
}
