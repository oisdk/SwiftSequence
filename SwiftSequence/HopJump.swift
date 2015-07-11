// MARK: - Eager

// MARK: Hop

public extension SequenceType {
  
  /// Returns an array with `n` elements of self hopped over. The sequence includes the
  /// first element of self.
  /// ```swift
  /// [1, 2, 3, 4, 5, 6, 7, 8].hop(2)
  ///
  /// [1, 4, 7]
  /// ```
  
  func hop(n: Int) -> [Generator.Element] {
    var i = 0
    return self.filter {
      _ -> Bool in
      if --i < 0 {
        i = n
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
  /// [1, 4, 7]
  /// ```
  
  func hop(n: Index.Stride) -> [Generator.Element] {
    let adjustedHop: Index.Stride = startIndex.distanceTo(startIndex.advancedBy(n).successor())
    return stride(from: startIndex, to: endIndex, by: adjustedHop).map{self[$0]}
  }
}

// MARK: Jump

public extension SequenceType {
  
  /// Returns an array with `n` elements of self jumped over. The sequence does not
  /// include the first element of self.
  /// ```swift
  /// [1, 2, 3, 4, 5, 6, 7, 8].jump(2)
  ///
  /// [3, 6]
  /// ```
  
  func jump(n: Int) -> [Generator.Element] {
    var i = n
    return self.filter {
      _ -> Bool in
      if --i < 0 {
        i = n
        return true
      } else {
        return false
      }
    }
  }
}

public extension CollectionType where Index : RandomAccessIndexType {

  /// Returns an array with `n` elements of self jumped over. The sequence does not
  /// include the first element of self.
  /// ```swift
  /// [1, 2, 3, 4, 5, 6, 7, 8].jump(2)
  ///
  /// [3, 6]
  /// ```
  
  func jump(n: Index.Stride) -> [Generator.Element] {
    let adjustedJump: Index.Stride = startIndex.distanceTo(startIndex.advancedBy(n).successor())
    return stride(from: startIndex.advancedBy(n), to: endIndex, by: adjustedJump).map{self[$0]}
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
      if --i < 0 {
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
    return HopGen(n: n, g: seq.generate(), i: 0)
  }
}

public extension LazySequenceType {
  
  /// Returns a lazy sequence with `n` elements of self hopped over. The sequence includes
  /// the first element of self.
  /// ```swift
  /// lazy([1, 2, 3, 4, 5, 6, 7, 8]).hop(2)
  ///
  /// 1, 4, 7
  /// ```
  
  func hop(n: Int) -> HopSeq<Self> {
    return HopSeq(seq: self, n: n)
  }
}

// MARK: Jump

public struct JumpGen<G: GeneratorType> : GeneratorType {
  
  private let n: Int
  private var g: G
  
  mutating public func next() -> G.Element? {
    for _ in 0..<n { g.next() }
    return g.next()
  }
}

public struct JumpSeq<S : SequenceType> : LazySequenceType {
  
  private let (seq, n): (S, Int)
  
  public func generate() -> JumpGen<S.Generator> {
    return JumpGen(n: n, g: seq.generate())
  }
}

public extension LazySequenceType {
  
  /// Returns a lazy sequence with `n` elements of self jumped over. The sequence does not
  /// include the first element of self.
  /// ```swift
  /// lazy([1, 2, 3, 4, 5, 6, 7, 8]).jump(2)
  ///
  /// 3, 6
  /// ```
  
  func jump(n: Int) -> JumpSeq<Self> {
    return JumpSeq(seq: self, n: n)
  }
}

// TODO: Change hop/jump semantics (hop(1) should return the same sequence).
// TODO: Add random access versions

// MARK: Random Access Hop:
//
//public struct LazyHopCollection<Base: CollectionType where Base.Index : RandomAccessIndexType, Base.Index : IntegerArithmeticType> : CollectionType {
//  
//  typealias Index = Base.Index
//  
//  private let base: Base
//  public let startIndex: Base.Index
//  public var endIndex: Base.Index
//  
//  private let hop: Base.Index
//  
//  public subscript(ind: Base.Index) -> Base.Generator.Element {
//    return base[ind * hop]
//  }
//  public func generate() -> IndexingGenerator<LazyHopCollection> {
//    return IndexingGenerator(self)
//  }
//  public init(_ base: Base, by: Base.Index) {
//    startIndex = base.startIndex
//    hop = by
//    self.base = base
//    let under = (base.endIndex / by)
//    endIndex = (base.endIndex % hop) == startIndex ? under : under.successor()
//  }
//}
//
//extension LazyRandomAccessCollection where Index : IntegerArithmeticType {
//  func hop(by: Index) -> LazyRandomAccessCollection<LazyHopCollection<LazyRandomAccessCollection<Base>>> {
//    return lazy(LazyHopCollection(self, by: by))
//  }
//}

