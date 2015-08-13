public struct SpecEnumerateGen<Base : CollectionType> : GeneratorType {
  
  private let base: Base
  private var i : Base.Index
  
  public mutating func next() -> (Base.Index, Base.Generator.Element)? {
    return i == base.endIndex ? nil : (i, base[i++])
  }
  
  private init(b: Base, i: Base.Index) {
    base = b
    self.i = i
  }
}

public struct SpecEnumerateSeq<Base : CollectionType> : LazySequenceType {
  
  private let col: Base
  public func generate() -> SpecEnumerateGen<Base> {
    return SpecEnumerateGen(b: col, i: col.startIndex)
  }
}

public extension CollectionType {
  
  /// Returns a lazy generator of tuples `(i, e)` where `i` is successive indices of self,
  /// and `e` is the respective elements. Effectively the same as `.enumerate()`, but the
  /// indices returned are `Self.Index`s, rather than `Int`s
  /// - SeeAlso: `enumerate()`
  
  func specEnumerate() -> SpecEnumerateSeq<Self> {
    return SpecEnumerateSeq(col: self)
  }
}


