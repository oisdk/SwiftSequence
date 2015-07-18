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
    var i = n - 1
    return self.filter {
      _ -> Bool in
      if ++i == n {
        i = 0
        return true
      } else {
        return false
      }
    }
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

//public struct LazyHopCollection<
//  Base: CollectionType where
//  Base.Index : RandomAccessIndexType,
//  Base.Index : IntegerArithmeticType
//  > : CollectionType {
//  
//    typealias Index = Base.Index
//    
//    private let base: LazyRandomAccessCollection<Base>
//    public let startIndex: Base.Index
//    public var endIndex: Base.Index
//    
//    private let hop: Base.Index
//    
//    public subscript(ind: Base.Index) -> Base.Generator.Element {
//      return base[ind * hop]
//    }
//    public func generate() -> IndexingGenerator<LazyHopCollection> {
//      return IndexingGenerator(self)
//    }
//    public init(_ base: LazyRandomAccessCollection<Base>, by: Base.Index) {
//      startIndex = base.startIndex
//      hop = by
//      self.base = base
//      let under = (base.endIndex / by)
//      endIndex = (base.endIndex % hop) == startIndex ? under : under.successor()
//    }
//}
//
//extension LazyRandomAccessCollection where Index : IntegerArithmeticType {
//  
//  /// Returns a lazy sequence with `n` elements of self hopped over. The sequence includes
//  /// the first element of self.
//  /// ```swift
//  /// lazy([1, 2, 3, 4, 5, 6, 7, 8]).hop(2)
//  ///
//  /// 1, 3, 5, 7
//  /// ```
//  
//  func hop(n: Index)
//    -> LazyRandomAccessCollection<LazyHopCollection<Base>> {
//      return lazy(LazyHopCollection(self, by: n))
//  }
//}