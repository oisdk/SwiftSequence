// MARK: - Eager

// MARK: Cycle n

public extension CollectionType {
  
  /// Returns an array of n cycles of self.
  /// ```swift
  /// [1, 2, 3].cycle(2)
  ///
  /// [1, 2, 3, 1, 2, 3]
  /// ```
  
  func cycle(n: Int) -> [Generator.Element] {
    return (0..<n).flatMap { (_: Int) in self }
  }
}

// MARK: - Lazy

// MARK: Cycle n
public struct CycleNGen<C: CollectionType> : GeneratorType, LazySequenceType {
  
  private let inner: C
  private var innerGen: C.Generator
  private var n: Int
  
  private init(col: C, n: Int) {
    self.inner = col
    self.innerGen = col.generate()
    self.n = n
  }
  
  public func generate() -> CycleNGen<C> {
    return self
  }
  
  public mutating func next() -> C.Generator.Element? {
    for ;n > 0;innerGen = inner.generate(), --n {
      if let next = innerGen.next() {
        return next
      }
    }
    return nil
  }
}

public extension LazySequenceType where Self : CollectionType {
  
  /// Returns a generator of n cycles of self.
  /// ```swift
  /// lazy([1, 2, 3]).cycle(2)
  ///
  /// 1, 2, 3, 1, 2, 3
  /// ```
  
  func cycle(n: Int) -> CycleNGen<Self> {
    return CycleNGen(col: self, n: n)
  }
}

// MARK: Cycle infinite

public struct CycleGen<C: CollectionType> : GeneratorType, LazySequenceType {
  
  private let inner: C
  private var innerGen: C.Generator
  
  private init(col: C) {
    self.inner = col
    self.innerGen = col.generate()
  }
  
  public func generate() -> CycleGen<C> {
    return self
  }
  
  public mutating func next() -> C.Generator.Element? {
    for ;;innerGen = inner.generate() {
      if let next = innerGen.next() {
        return next
      }
    }
  }
}

public extension CollectionType {
  
  /// Returns an infinite generator of cycles of self.
  /// ```swift
  /// [1, 2, 3].cycle()
  ///
  /// 1, 2, 3, 1, 2, 3, 1...
  /// ```
  
  func cycle() -> CycleGen<Self> {
    return CycleGen(col: self)
  }
}
