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
