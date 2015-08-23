// MARK: - Eager

// MARK: Hop

public extension SequenceType {
  
  /// Returns an array with `n` elements of self hopped over. The sequence includes the
  /// first element of self.
  /// ```swift
  /// [1, 2, 3, 4, 5, 6, 7, 8].hop(2)
  ///
  /// [1, 3, 5, 7]
  /// ```
  
  public func hop(n: Int) -> [Generator.Element] {
    var result: [Generator.Element] = []
    result.reserveCapacity((underestimateCount() / n).successor())
    var i = 1
    for element in self where --i == 0 {
      i = n
      result.append(element)
    }
    return result
  }
}

public extension CollectionType where Index : RandomAccessIndexType {
  
  /// Returns an array with `n` elements of self hopped over. The sequence includes the
  /// first element of self.
  /// ```swift
  /// [1, 2, 3, 4, 5, 6, 7, 8].hop(2)
  ///
  /// [1, 3, 5, 7]
  /// ```
  
  func hop(n: Index.Stride) -> [Generator.Element] {
    return stride(from: startIndex, to: endIndex, by: n).map{self[$0]}
  }
}

// MARK: - Lazy

// MARK: Hop

public struct HopGen<G: GeneratorType> : GeneratorType {

  private let n: Int
  private var g: G
  private var i: Int

  mutating public func next() -> G.Element? {

    while let next = g.next() {
      if --i == 0 {
        i = n
        return next
      }
    }
    return nil
  }
}

public struct HopSeq<S : SequenceType> : LazySequenceType {

  private let (seq, n): (S, Int)

  public func generate() -> HopGen<S.Generator> {
    return HopGen(n: n, g: seq.generate(), i: 1)
  }
}

public extension LazySequenceType {
  
  /// Returns a lazy sequence with `n` elements of self hopped over. The sequence includes
  /// the first element of self.
  /// ```swift
  /// lazy([1, 2, 3, 4, 5, 6, 7, 8]).hop(2)
  ///
  /// 1, 3, 5, 7
  /// ```
  
  func hop(n: Int) -> HopSeq<Self> {
    return HopSeq(seq: self, n: n)
  }
}

// MARK: Random Access Hop:

public struct RandomAccessHopGen<
  Base : CollectionType where
  Base.Index : RandomAccessIndexType
  > : GeneratorType {

  private var g: StrideToGenerator<Base.Index>
  private let b: Base

  public mutating func next() -> Base.Generator.Element? {
    return g.next().map{ b[$0] }
  }
}

public struct RandomAccessHopSeq<
  Base : CollectionType where
  Base.Index : RandomAccessIndexType
  > : SequenceType {

  private let base: Base
  private let by  : Base.Index.Stride

  public func generate() -> RandomAccessHopGen<Base> {
    return RandomAccessHopGen(
      g: stride(from: base.startIndex, to: base.endIndex, by: by).generate(),
      b: base
    )
  }
}

extension LazySequenceType where Self : CollectionType, Self.Index : RandomAccessIndexType {
  
  /// Returns a lazy sequence with `n` elements of self hopped over. The sequence includes
  /// the first element of self.
  /// ```swift
  /// lazy([1, 2, 3, 4, 5, 6, 7, 8]).hop(2)
  ///
  /// 1, 3, 5, 7
  /// ```
  
  public func hop(n: Index.Stride) -> RandomAccessHopSeq<Self> {
    return RandomAccessHopSeq(base: self, by: n)
  }
}