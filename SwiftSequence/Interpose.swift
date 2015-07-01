// MARK: - Eager

// MARK: Interpose with single element

public extension SequenceType {
  
  /// Returns an array that alternates between successive elements of self and element
  /// ```swift
  /// [1, 2, 3].interpose(10)
  ///
  /// [1, 10, 2, 10, 3]
  /// ```
  
  func interpose(element: Generator.Element) -> [Generator.Element] {
    var g = self.generate()
    
    return g.next().map {
      var ret = [$0]
      while let next = g.next() {
        ret.append(element)
        ret.append(next)
      }
      return ret
    } ?? []
    
  }
  
  /// Returns an array that alternates between n successive elements of self and element
  /// ```swift
  /// [1, 2, 3, 4, 5].interpose(10, n: 2)
  ///
  /// [1, 2, 10, 3, 4, 10, 5]
  /// ```
  
  func interpose(element: Generator.Element, n: Int) -> [Generator.Element] {
    
    var ret: [Generator.Element] = []
    var g = self.generate()
    var i = n + 1
    
    while let next = g.next() {
      if --i == 0 {
        ret.append(element)
        i = n
      }
      ret.append(next)
    }
    return ret
  }
}

// MARK: Interpose with collection

public extension SequenceType {
  
  /// Returns an array that alternates between successive elements of self and elements of
  /// a colletion
  /// ```swift
  /// [1, 2, 3].interpose([10, 20])
  ///
  /// [1, 10, 20, 2, 10, 20, 3]
  /// ```
  
  func interpose<C : CollectionType where C.Generator.Element == Generator.Element>
    (col: C) -> [Generator.Element] {
      var g = self.generate()
      return g.next().map {
        var ret = [$0]
        while let next = g.next() {
          ret.extend(col)
          ret.append(next)
        }
        return ret
      } ?? []
  }
  
  /// Returns an array that alternates between n successive elements of self and elements
  /// of a colletion
  /// ```swift
  /// [1, 2, 3, 4, 5].interpose([10, 20], n: 2)
  ///
  /// [1, 2, 10, 20, 3, 4, 10, 20, 5]
  /// ```
  
  func interpose<C : CollectionType where C.Generator.Element == Generator.Element>
    (col: C, n: Int) -> [Generator.Element] {
      var g = self.generate()
      return g.next().map {
        var i = n
        var ret = [$0]
        while let next = g.next() {
          if --i == 0 {
            ret.extend(col)
            i = n
          }
          ret.append(next)
        }
        return ret
      } ?? []
      
  }
}

// MARK: Interdigitate

/// Returns an array of two sequences interdigitated
/// ```swift
/// interdig([1, 2, 3], [10, 20, 30])
///
/// [1, 10, 2, 20, 3, 30]
/// ```

public func interdig<
  S0 : SequenceType, S1 : SequenceType where
  S0.Generator.Element == S1.Generator.Element
  >(s0: S0, _ s1: S1) -> [S0.Generator.Element] {
    
    var ret: [S0.Generator.Element] = []
    
    var (g0, g1) = (s0.generate(), s1.generate())
    
    while let e0 = g0.next(), e1 = g1.next() {
      ret.append(e0)
      ret.append(e1)
    }
    
    return ret
}

/// Returns an array of two sequences interdigitated, with the respective length of each
/// interdigitation specified
/// - Parameter s0Len: The length of the first sequence's interdigitations
/// - Parameter s1Len: The length of the second sequence's interdigitations
/// ```swift
/// interdig([1, 2, 3, 4, 5], [10, 20, 30, 40, 50, 60], s0Len: 2, s1Len: 3)
///
/// [1, 2, 10, 20, 30, 3, 4, 40, 50, 60, 5]
/// ```

public func interdig<
  S0 : SequenceType, S1 : SequenceType where
  S0.Generator.Element == S1.Generator.Element
  >(s0: S0, _ s1: S1, s0Len: Int, s1Len: Int) -> [S0.Generator.Element] {
    
    var ret: [S0.Generator.Element] = []
    
    var (g0, g1) = (s0.generate(), s1.generate())
    
    for ;; {
      for _ in 0..<s0Len {
        if let next = g0.next() {
          ret.append(next)
        } else {
          return ret
        }
      }
      for _ in 0..<s1Len {
        if let next = g1.next() {
          ret.append(next)
        } else {
          return ret
        }
      }
    }
}

// MARK: - Lazy

// MARK: Interpose with single element

public struct InterposeElGen<G : GeneratorType> : GeneratorType {
  
  private let element: G.Element
  private var g: G
  private let n: Int
  private var count: Int
  
  init(n: Int, g: G, element: G.Element) {
    self.n = n
    self.count = n
    self.element = element
    self.g = g
  }
  
  public mutating func next() -> G.Element? {
    return --count < 0 ? {count = n; return element}() : g.next()
  }
}

public struct InterposeElSeq<S : SequenceType> : LazySequenceType {
  
  private let element: InterposeElGen<S.Generator>.Element
  private let n: Int
  private let seq: S
  
  public func generate() -> InterposeElGen<S.Generator> {
    return InterposeElGen(n: n, g: seq.generate(), element: element)
  }
}

public extension LazySequenceType {
  
  /// Returns a lazy sequence that alternates between successive elements of self and an
  /// element
  /// ```swift
  /// lazy([1, 2, 3]).interpose(10)
  ///
  /// 1, 10, 2, 10, 3, 10
  /// ```
  
  func interpose(element: Generator.Element) -> InterposeElSeq<Self> {
    return InterposeElSeq(element: element, n: 1, seq: self)
  }
  
  /// Returns a lazy sequence that alternates between n successive elements of self and an
  /// element
  /// ```swift
  /// lazy([1, 2, 3, 4, 5]).interpose(10, n: 2)
  ///
  /// 1, 2, 10, 3, 4, 10, 5
  /// ```
  
  func interpose(element: Generator.Element, n: Int) -> InterposeElSeq<Self> {
    return InterposeElSeq(element: element, n: n, seq: self)
  }
}

// MARK: Interpose with collection

public struct InterposeColGen<
  G : GeneratorType,
  C: CollectionType where
  G.Element == C.Generator.Element
  > : GeneratorType {
  
  private let col: C
  private var g: G
  private let n: Int
  private var count: Int
  private var colG: C.Generator
  
  private init(col: C, g: G, n: Int) {
    self.n = n
    self.count = n + 1
    self.col = col
    self.g = g
    self.colG = self.col.generate()
  }
  
  public mutating func next() -> G.Element? {
    return --count <= 0 ? {
      colG.next() ?? {
        count = n
        colG = col.generate()
        return g.next()
      }()}() : g.next()
  }
}

public struct InterposeColSeq<
  S : SequenceType,
  C: CollectionType where
  S.Generator.Element == C.Generator.Element
  > : LazySequenceType {
  
  private let col: C
  private let n: Int
  private let seq: S
  
  public func generate() -> InterposeColGen<S.Generator, C> {
    return InterposeColGen(col: col, g: seq.generate(), n: n)
  }
}

public extension LazySequenceType {
  
  /// Returns a lazy sequence that alternates between successive elements of self and
  /// elements of a colletion
  /// ```swift
  /// lazy([1, 2, 3]).interpose([10, 20])
  ///
  /// 1, 10, 20, 2, 10, 20, 3, 10, 20
  /// ```
  
  func interpose<
    C: CollectionType where
    C.Generator.Element == Generator.Element
    >(elements: C) -> InterposeColSeq<Self, C> {
      return InterposeColSeq(col: elements, n: 1, seq: self)
  }
  
  /// Returns a lazy sequence that alternates between n successive elements of self and
  /// elements of a colletion
  /// ```swift
  /// lazy([1, 2, 3, 4, 5]).interpose([10, 20], n: 2)
  ///
  /// 1, 2, 10, 20, 3, 4, 10, 20, 5
  /// ```
  
  func interpose<
    C: CollectionType where
    C.Generator.Element == Generator.Element
    >(elements: C, n: Int) -> InterposeColSeq<Self, C> {
      return InterposeColSeq(col: elements, n: n, seq: self)
  }
}

// MARK: Interdigitate

public struct InterDigGen<
  G0 : GeneratorType,
  G1 : GeneratorType where
  G0.Element == G1.Element
  > : GeneratorType {
  
  private var g0: G0
  private var g1: G1
  
  private let aN: Int
  private let bN: Int
  
  private var count: Int
  
  public mutating func next() -> G0.Element? {
    for (--count;;count = aN) {
      if count >= bN { return count < 0 ? g1.next() : g0.next() }
    }
  }
}

public struct InterDigSeq<
  S0 : LazySequenceType,
  S1 : LazySequenceType where
  S0.Generator.Element == S1.Generator.Element
  > : LazySequenceType {
    
  private let s0: S0
  private let s1: S1
  
  private let aN: Int
  private let bN: Int
  
  public func generate() -> InterDigGen<S0.Generator, S1.Generator> {
    return InterDigGen(
      g0: s0.generate(),
      g1: s1.generate(),
      aN: aN - 1,
      bN: -bN,
      count: aN
    )
  }
}

/// Returns a lazy sequence of two sequences interdigitated
/// ```swift
/// interdig(lazy([1, 2, 3]), lazy([10, 20, 30]))
///
/// 1, 10, 2, 20, 3, 30
/// ```

public func interdig<
  S0 : LazySequenceType, S1 : LazySequenceType where
  S0.Generator.Element == S1.Generator.Element
  >(s0: S0, _ s1: S1) -> InterDigSeq<S0, S1> {
    return InterDigSeq(s0: s0, s1: s1, aN: 1, bN: 1)
}

/// Returns a lazy sequence of two sequences interdigitated, with the respective length of
/// each interdigitation specified
/// - Parameter s0Len: The length of the first sequence's interdigitations
/// - Parameter s1Len: The length of the second sequence's interdigitations
/// ```swift
/// interdig(lazy([1, 2, 3, 4, 5]), lazy([10, 20, 30, 40, 50, 60]), s0Len: 2, s1Len: 3)
///
/// 1, 2, 10, 20, 30, 3, 4, 40, 50, 60, 5
/// ```

public func interdig<
  S0 : SequenceType, S1 : SequenceType where
  S0.Generator.Element == S1.Generator.Element
  >(s0: S0, _ s1: S1, s0Len: Int, s1Len: Int = 1) -> InterDigSeq<S0, S1> {
    return InterDigSeq(s0: s0, s1: s1, aN: s0Len, bN: s1Len)
}