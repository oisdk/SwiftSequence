// MARK: - Eager

// MARK: Cartesian Product

private extension GeneratorType where Element : CollectionType {
  mutating private func product() -> [[Element.Generator.Element]] {
    return self.next().map {
      let pProd = self.product()
      return $0.flatMap {
        el in pProd.map {
          [el] + $0
        }
      }
    } ?? [[]]
  }
}

public extension SequenceType where Generator.Element : SequenceType, Generator.Element : CollectionType {
  
  /// Returns a cartesian product of self
  /// ```swift
  /// [[1, 2], [3, 4]].product()
  /// [[1, 3], [1, 4], [2, 3], [2, 4]]
  /// ```
  
  public func product() -> [[Generator.Element.Generator.Element]] {
    var g = self.generate()
    return g.product()
  }
}

public extension SequenceType where Generator.Element : SequenceType {
  
  /// Returns a cartesian product of self
  /// ```swift
  /// [[1, 2], [3, 4]].product()
  /// [[1, 3], [1, 4], [2, 3], [2, 4]]
  /// ```
  
  public func product() -> [[Generator.Element.Generator.Element]] {
    return self.map(Array.init).product()
  }
}

/// Cartesian product
/// ```swift
/// product([1, 2], [3, 4])
/// [[1, 3], [1, 4], [2, 3], [2, 4]]
/// ```

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

public extension SequenceType where Generator.Element : SequenceType {
  
  /// Returns a transposed self
  /// ```swift
  /// [[1, 2, 3], [1, 2, 3], [1, 2, 3]].transpose()
  ///
  /// [[1, 1, 1], [2, 2, 2], [3, 3, 3]]
  /// ```
  
  func transpose() -> [[Generator.Element.Generator.Element]] {
    var ret: [[Generator.Element.Generator.Element]] = [[]]
    for var gens = self.map{$0.generate()};; ret.append([]) {
      for i in gens.indices {
        if let next = gens[i].next() {
          ret[ret.endIndex.predecessor()].append(next)
        } else {
          ret.removeLast()
          return ret
        }
      }
    }
  }
}

// MARK: - Lazy

// MARK: Cartesian Product

public struct ProdGen<C : CollectionType> : GeneratorType {
  
  private let cols: [C] // Must be collections, not sequences, in order to be multi-pass
  
  private var gens: [C.Generator]
  private var curr: [C.Generator.Element]
  
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
    self.curr = dropLast(gens).indices.map{gens[$0].next()!} + [self.cols.last!.first!]
    /**
    set curr to the first value of each of the generators, except the last: don't
    increment this generator, so that the first value returned contains it.
    */
    self.gens = gens
  }
}

public struct ProdSeq<C : CollectionType> : LazySequenceType {
  private let cols: [C]
  public func generate() -> ProdGen<C> {
    return ProdGen( cols: cols )
  }
}

/// Lazy Cartesian Product
/// ```swift
/// lazyProduct([1, 2], [3, 4])
///
/// [1, 3], [1, 4], [2, 3], [2, 4]
/// ```

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
  
  func lazyProduct() -> ProdSeq<[Generator.Element.Generator.Element]> {
    return ProdSeq(cols: self.map(Array.init))
  }
}

public extension SequenceType where Generator.Element : CollectionType {
  
  /// Lazy Cartesian Product
  /// ```swift
  /// [[1, 2], [3, 4]].lazyProduct()
  ///
  /// [1, 3], [1, 4], [2, 3], [2, 4]
  /// ```
  
  func lazyProduct() -> ProdSeq<Generator.Element> {
    return ProdSeq(cols: Array(self))
  }
}

// MARK: Transposition

public struct TransposeGen<T, G : GeneratorType where G.Element == T> : GeneratorType {
  private var gens: [G]
  mutating public func next() -> [T]? {
    let row = gens.indices.flatMap {gens[$0].next()}
    return row.count == gens.count ? row : nil
  }
}

public struct TransposeSeq<
  S : SequenceType where
  S.Generator.Element : SequenceType
  > : LazySequenceType {
  private let seq: S
  public func generate()
    -> TransposeGen<S.Generator.Element.Generator.Element, S.Generator.Element.Generator>{
    return TransposeGen(gens: self.seq.map{ $0.generate() })
  }
}

public extension LazySequenceType where Generator.Element: SequenceType {
  
  /// Returns a lazily transposed self
  /// ```swift
  /// lazy([[1, 2, 3], [1, 2, 3], [1, 2, 3]]).transpose()
  ///
  /// [1, 1, 1], [2, 2, 2], [3, 3, 3]
  /// ```
  
  func transpose() -> TransposeSeq<Self> {
    return TransposeSeq(seq: self)
  }
}
