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
  
  func chunk(n : Int) -> [[Generator.Element]] {
    var g = self.generate()
    var ret: [[Generator.Element]] = [[]]
    while let next = g.next() {
      if ret.last!.count < n {
        ret[ret.endIndex.predecessor()].append(next)
      } else {
        ret.append([next])
      }
    }
    return ret
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
    var g = self.generate()
    
    var window: [Generator.Element] = []
    
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

// MARK: Split

public extension SequenceType {
  
  /// Returns an array of arrays that end with elements that return true for `isSplit`
  /// ```swift
  /// [1, 3, 4, 4, 5, 6].splitAt {$0 % 2 == 0}
  ///
  /// [[1, 3, 4], [4], [5, 6]]
  /// ```
  
  func splitAt(@noescape isSplit : Generator.Element -> Bool) -> [[Generator.Element]] {
    var g = self.generate()
    var ret: [[Generator.Element]] = [[]]
    while let next = g.next() {
      ret[ret.endIndex.predecessor()].append(next)
      if isSplit(next) { ret.append([]) }
    }
    if ret.last?.isEmpty == true { ret.removeLast() }
    return ret
  }
}

// MARK: - Lazy

// MARK: Chunk

public struct ChunkGen<G : GeneratorType> : GeneratorType {
  
  private var g: G
  private let n: Int
  private var c: [G.Element]
  
  public mutating func next() -> [G.Element]? {
    var i = n
    c = []
    while --i >= 0, let next = g.next() { c.append(next) }
    return c.isEmpty ? nil : c
  }
  
  private init(g: G, n: Int) {
    self.g = g
    self.n = n
    self.c = []
    self.c.reserveCapacity(n)
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

public struct WindowGen<G : GeneratorType> : GeneratorType {
  
  private var g: G
  private var window: [G.Element]?
  private var n: Int
  
  mutating public func next() -> [G.Element]? {
    if window != nil {
      return g.next().map {
        window!.removeAtIndex(0)
        window!.append($0)
        return window!
      }
    } else {
      while --n >= 0, let next = g.next() {
        window?.append(next) ?? {
          window = [next]
          window!.reserveCapacity(n)
        }()
      }
      return window
    }
  }
  
  private init(g: G, n: Int) {
    self.g = g
    self.n = n
    self.window = nil
  }
}

public struct WindowSeq<S : SequenceType> : LazySequenceType {
  
  private let seq: S
  private let n: Int
  
  public func generate() -> WindowGen<S.Generator> {
    return WindowGen(g: seq.generate(), n: n)
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

// MARK: Split

public struct SplitAtGen<G : GeneratorType> : GeneratorType {
  
  private let isSplit: G.Element -> Bool
  private var g: G
  
  mutating public func next() -> [G.Element]? {
    var ret: [G.Element]?
    while let next = g.next() {
      ret?.append(next) ?? {ret = [next]}()
      if isSplit(next) { return ret }
    }
    return ret
  }
}

public struct SplitSeq<S : SequenceType> : LazySequenceType {
  
  private let seq: S
  private let isSplit: S.Generator.Element -> Bool
  
  public func generate() -> SplitAtGen<S.Generator> {
    return SplitAtGen(isSplit: isSplit, g: seq.generate())
  }
}

public extension LazySequenceType {
  
  /// Returns a lazily-generated sequence of arrays that end with elements that return
  /// true for `isSplit`
  /// ```swift
  /// lazy([1, 3, 4, 4, 5, 6]).splitAt {$0 % 2 == 0}
  ///
  /// [1, 3, 4], [4], [5, 6]
  /// ```
  
  func splitAt(isSplit: Generator.Element -> Bool) -> SplitSeq<Self> {
    return SplitSeq(seq: self, isSplit: isSplit)
  }
}
