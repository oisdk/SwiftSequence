// MARK: - Eager

// MARK: Cartesian Product

private extension GeneratorType where Element : CollectionType {
  mutating private func product() -> [[Element.Generator.Element]] {
    guard let x = next() else { return [[]] }
    let xs = product()
    return x.flatMap { h in xs.map { [h] + $0 } }
  }
}

public extension SequenceType where Generator.Element : SequenceType, Generator.Element : CollectionType {
  
  /// Returns a cartesian product of self
  /// ```swift
  /// [[1, 2], [3, 4]].product()
  /// [[1, 3], [1, 4], [2, 3], [2, 4]]
  /// ```
  @warn_unused_result
  public func product() -> [[Generator.Element.Generator.Element]] {
    var g = generate()
    return g.product()
  }
}

public extension SequenceType where Generator.Element : SequenceType {
  
  /// Returns a cartesian product of self
  /// ```swift
  /// [[1, 2], [3, 4]].product()
  /// [[1, 3], [1, 4], [2, 3], [2, 4]]
  /// ```
  @warn_unused_result
  public func product() -> [[Generator.Element.Generator.Element]] {
    return map(Array.init).product()
  }
}

/// Cartesian product
/// ```swift
/// product([1, 2], [3, 4])
/// [[1, 3], [1, 4], [2, 3], [2, 4]]
/// ```
@warn_unused_result
public func product<C : CollectionType>(cols: C...) -> [[C.Generator.Element]] {
  return cols.product()
}

/// Cartesian product
/// ```swift
/// product([1, 2], [3, 4])
/// [[1, 3], [1, 4], [2, 3], [2, 4]]
/// ```

public func product<S : SequenceType>(cols: S...) -> [[S.Generator.Element]] {
  return cols.product()
}

// MARK: Transposition

private extension SequenceType {
  private func mapM<U>(@noescape transform: Generator.Element -> U?) -> [U]? {
    var result: [U] = []
    result.reserveCapacity(underestimateCount())
    for e in self {
      if let r = transform(e) { result.append(r) } else { return nil }
    }
    return result
  }
}

public extension SequenceType where Generator.Element : SequenceType {
  
  /// Returns a transposed self
  /// ```swift
  /// [[1, 2, 3], [1, 2, 3], [1, 2, 3]].transpose()
  ///
  /// [[1, 1, 1], [2, 2, 2], [3, 3, 3]]
  /// ```
  @warn_unused_result
  func transpose() -> [[Generator.Element.Generator.Element]] {
    return Array(TransposeSeq(seq: self))
  }
}

// MARK: - Lazy

// MARK: Cartesian Product
/// :nodoc:
public struct ProdGen<C : CollectionType> : GeneratorType {
  
  private let cols: [C] // Must be collections, not sequences, in order to be multi-pass
  
  private var gens: [C.Generator]
  private var curr: [C.Generator.Element]
  /// :nodoc:
  public mutating func next() -> [C.Generator.Element]? {
    
    for i in gens.indices.reverse() { // Loop through generators in reverse order, rolling over
      if let n = gens[i].next() {     // if generator isn't finished, just increment that column, return
        curr[i] = n
        return curr
      } else {                        // generator is finished
        gens[i] = cols[i].generate()  // reset the generator
        curr[i] = gens[i].next()!     // set the current column to the first element of the generator
      }
    }
    return nil
  }
  
  private init(cols: [C]) {
    var gens = cols.map{$0.generate()}
    self.cols = cols
    curr = gens.dropLast().indices.map{gens[$0].next()!} + [self.cols.last!.first!]
    /**
    set curr to the first value of each of the generators, except the last: don't
    increment this generator, so that the first value returned contains it.
    */
    self.gens = gens
  }
}
/// :nodoc:
public struct ProdSeq<C : CollectionType> : LazySequenceType {
  private let cols: [C]
  /// :nodoc:
  public func generate() -> ProdGen<C> {
    return ProdGen( cols: cols )
  }
  /// :nodoc:
  public func underestimateCount() -> Int {
    return cols.reduce(1) { (n,c) in n * c.underestimateCount() }
  }
}

/// Lazy Cartesian Product
/// ```swift
/// lazyProduct([1, 2], [3, 4])
///
/// [1, 3], [1, 4], [2, 3], [2, 4]
/// ```
@warn_unused_result
public func lazyProduct<C : CollectionType>
  (cols: C...) -> ProdSeq<C> {
    return ProdSeq(cols: cols)
}

/// Lazy Cartesian Product
/// ```swift
/// lazyProduct([1, 2], [3, 4])
///
/// [1, 3], [1, 4], [2, 3], [2, 4]
/// ```
@warn_unused_result
public func lazyProduct<S : SequenceType>
  (cols: S...) -> ProdSeq<[S.Generator.Element]> {
    return ProdSeq(cols: cols.map(Array.init))
}

public extension SequenceType where Generator.Element : SequenceType {
  
  /// Lazy Cartesian Product
  /// ```swift
  /// [[1, 2], [3, 4]].lazyProduct()
  ///
  /// [1, 3], [1, 4], [2, 3], [2, 4]
  /// ```
  @warn_unused_result
  func lazyProduct() -> ProdSeq<[Generator.Element.Generator.Element]> {
    return ProdSeq(cols: map(Array.init))
  }
}

public extension SequenceType where Generator.Element : CollectionType {
  
  /// Lazy Cartesian Product
  /// ```swift
  /// [[1, 2], [3, 4]].lazyProduct()
  ///
  /// [1, 3], [1, 4], [2, 3], [2, 4]
  /// ```
  @warn_unused_result
  func lazyProduct() -> ProdSeq<Generator.Element> {
    return ProdSeq(cols: Array(self))
  }
}

// MARK: Transposition
/// :nodoc:
public struct TransposeGen<T, G : GeneratorType where G.Element == T> : GeneratorType {
  private var gens: [G]
  /// :nodoc:
  mutating public func next() -> [T]? {
    return gens.indices.mapM { i in gens[i].next() }
  }
}
/// :nodoc:
public struct TransposeSeq<
  S : SequenceType where
  S.Generator.Element : SequenceType
  > : LazySequenceType {
  private let seq: S
  /// :nodoc:
  public func generate()
    -> TransposeGen<S.Generator.Element.Generator.Element, S.Generator.Element.Generator>{
    return TransposeGen(gens: seq.map { g in g.generate() })
  }
}

public extension TransposeSeq where S: CollectionType {
  @warn_unused_result
  public func underestimateCount() -> Int {
    return seq.first?.underestimateCount() ?? 0
  }
}

public extension LazySequenceType where Generator.Element: SequenceType {
  
  /// Returns a lazily transposed self
  /// ```swift
  /// lazy([[1, 2, 3], [1, 2, 3], [1, 2, 3]]).transpose()
  ///
  /// [1, 1, 1], [2, 2, 2], [3, 3, 3]
  /// ```
  @warn_unused_result
  func transpose() -> TransposeSeq<Self> {
    return TransposeSeq(seq: self)
  }
}
