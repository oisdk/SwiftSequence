// MARK: - Eager

// MARK: Chunk

public extension SequenceType {
  
  /// Returns an array of arrays of n non-overlapping elements of self
  /// - Parameter n: The size of the chunk
  /// - SeeAlso: `func window(n: Int) -> [[Self.Generator.Element]]`
  ///  ```swift
  ///  [1, 2, 3, 4, 5].chunk(2)
  ///
  ///  [[1, 2], [3, 4], [5]]
  /// ```
  
  public func chunk(n : Int) -> [[Generator.Element]] {
    var result: [[Generator.Element]] = []
    var crChnk:  [Generator.Element]  = []
    crChnk.reserveCapacity(n)
    result.reserveCapacity(underestimateCount() / n)
    var i = n
    for element in self {
      crChnk.append(element)
      if --i == 0 {
        result.append(crChnk)
        crChnk.removeAll(keepCapacity: true)
        i = n
      }
    }
    if !crChnk.isEmpty { result.append(crChnk) }
    return result
  }
}

public extension CollectionType {
  public func chunk(n: Index.Distance) -> [SubSequence] {
    var result: [SubSequence] = []
    var i = startIndex
    while i != endIndex {
      let j = i.advancedBy(n, limit: endIndex)
      result.append(self[i..<j])
      i = j
    }
    return result
  }
}

// MARK: Window

public extension SequenceType {
  
  /// Returns an array of arrays of n overlapping elements of self
  /// - Parameter n: The size of the window
  /// - SeeAlso: `func chunk(n: Int) -> [[Self.Generator.Element]]`
  ///  ```swift
  ///  [1, 2, 3, 4].window(2)
  ///
  ///  [[1, 2], [2, 3], [3, 4]]
  ///   ```
  
  func window(n : Int) -> [[Generator.Element]] {
    var g = generate()
    
    var window: [Generator.Element] = []
    
    window.reserveCapacity(n)
    
    while window.count < n {
      if let next = g.next() {
        window.append(next)
      } else {
        return [window]
      }
    }
    
    var ret = [window]
    while let next = g.next() {
      window.removeAtIndex(0)
      window.append(next)
      ret.append(window)
    }
    
    return ret
  }
}

// MARK: - Lazy

// MARK: Chunk

public struct ChunkGen<G : GeneratorType> : GeneratorType {
  
  private var g: G
  private let n: Int
  
  public mutating func next() -> [G.Element]? {
    var i = n
    return g.next().map {
      var c = [$0]
      c.reserveCapacity(n)
      while --i > 0, let next = g.next() { c.append(next) }
      return c
    }
  }
}

public struct ChunkSeq<S : SequenceType> : LazySequenceType {
  
  private let seq: S
  private let n: Int
  
  public func generate() -> ChunkGen<S.Generator> {
    return ChunkGen(g: seq.generate(), n: n)
  }
}

public extension LazySequenceType {
  
  /// Returns lazily-generated arrays of n non-overlapping elements of self
  /// - Parameter n: The size of the chunk
  /// - SeeAlso: `func window(n: Int) -> WindowSeq<Self>`
  ///  ```swift
  ///  lazy([1, 2, 3, 4, 5]).chunk(2)
  ///
  ///  [1, 2], [3, 4], [5]
  /// ```
  func chunk(n: Int) -> ChunkSeq<Self> {
    return ChunkSeq(seq: self, n: n)
  }
}

// MARK: Window

public struct WindowGen<Element> : GeneratorType {
  
  private let g: () -> Element?
  private var window: [Element]?
  
  mutating public func next() -> [Element]? {
    return window.map { result in
      if let element = g() {
        window!.append(element)
        window!.removeFirst()
      } else { window = nil }
      return result
    }
  }
}

/// :nodoc:

public struct WindowSeq<S : SequenceType> : LazySequenceType {
  
  private let seq: S
  private let n: Int
  
  public func generate() -> WindowGen<S.Generator.Element> {
    var window: [S.Generator.Element] = []
    window.reserveCapacity(n + 1)
    var g = seq.generate()
    for _ in 0..<n {
      guard let next = g.next() else { return WindowGen(g: {nil}, window: window) }
      window.append(next)
    }
    return WindowGen(g: {g.next()}, window: window)
  }
}

public extension LazySequenceType {
  
  /// Returns lazily-generated arrays of n overlapping elements of self
  /// - Parameter n: The size of the window
  /// - SeeAlso: `func chunk(n: Int) -> ChunkSeq<Self>`
  ///  ```swift
  ///  lazy([1, 2, 3, 4]).window(2)
  ///
  ///  [1, 2], [2, 3], [3, 4]
  ///   ```
  
  func window(n: Int) -> WindowSeq<Self> {
    return WindowSeq(seq: self, n: n)
  }
}
