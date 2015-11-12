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
/// :nodoc:
public struct CycleNGen<C: CollectionType> : GeneratorType, LazySequenceType {
  
  private let inner: C
  private var innerGen: C.Generator
  private var n: Int
  /// :nodoc:
  public mutating func next() -> C.Generator.Element? {
    repeat {
      if let next = innerGen.next() { return next }
      innerGen = inner.generate()
    } while --n > 0
    return nil
  }
}

public extension LazySequenceType where Self : CollectionType {
  
  /// Returns a generator of n cycles of self.
  /// ```swift
  /// [1, 2, 3].lazy.cycle(2)
  ///
  /// 1, 2, 3, 1, 2, 3
  /// ```
  
  func cycle(n: Int) -> CycleNGen<Self> {
    return CycleNGen(inner: self, innerGen: generate(), n: n)
  }
}

// MARK: Cycle infinite
/// :nodoc:
public struct CycleGen<C: CollectionType> : GeneratorType, LazySequenceType {
  
  private let inner: C
  private var innerGen: C.Generator
  /// :nodoc:
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
    return CycleGen(inner: self, innerGen: generate())
  }
}
