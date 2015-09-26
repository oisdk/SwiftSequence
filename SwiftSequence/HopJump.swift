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
  
  func hop(n: Int) -> [Generator.Element] {
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

extension CollectionType where Index : RandomAccessIndexType {
  
  /// Returns an array with `n` elements of self hopped over. The sequence includes the
  /// first element of self.
  /// ```swift
  /// [1, 2, 3, 4, 5, 6, 7, 8].hop(2)
  ///
  /// [1, 3, 5, 7]
  /// ```
  
  public func hop(n: Index.Stride) -> [Generator.Element] {
    return startIndex.stride(to: endIndex, by: n).map{self[$0]}
  }
}

extension CollectionType where Index == Int {
  
  /// Returns an array with `n` elements of self hopped over. The sequence includes the
  /// first element of self.
  /// ```swift
  /// [1, 2, 3, 4, 5, 6, 7, 8].hop(2)
  ///
  /// [1, 3, 5, 7]
  /// ```
  
  public func hop(n: Int) -> [Generator.Element] {
    return startIndex.stride(to: endIndex, by: n).map{self[$0]}
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
  /// [1, 2, 3, 4, 5, 6, 7, 8].lazy.hop(2)
  ///
  /// 1, 3, 5, 7
  /// ```
  
  func hop(n: Int) -> HopSeq<Self> {
    return HopSeq(seq: self, n: n)
  }
}

// MARK: Random Access Hop:

public struct RandomAccessHopCollection<
  Base : CollectionType where
  Base.Index : RandomAccessIndexType,
  Base.Index.Distance : ForwardIndexType
  > : LazyCollectionType {
  
  private let base: Base
  private let by  : Base.Index.Stride
  private let fac : Base.Index.Distance
  
  public var startIndex: Base.Index.Distance { return 0 }
  public let endIndex: Base.Index.Distance
  public subscript(i: Base.Index.Distance) -> Base.Generator.Element {
    return base[base.startIndex.advancedBy(fac * i)]
  }
  
  private init(_ b: Base, _ by: Base.Index.Stride) {
    base = b
    self.by = by
    fac = base.startIndex.distanceTo(base.startIndex.advancedBy(by))
    endIndex = (base.startIndex.distanceTo(base.endIndex.predecessor()) / fac).successor()
  }
}

extension LazyCollectionType where Index : RandomAccessIndexType, Index.Distance : ForwardIndexType {
  
  public func hop(n: Index.Stride) -> RandomAccessHopCollection<Self> {
    return RandomAccessHopCollection(self, n)
  }
}