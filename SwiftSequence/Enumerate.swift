public struct SpecEnumerateGen<Base : CollectionType> : GeneratorType {
  
  private var eG: Base.Generator
  private let sI: Base.Index
  private var i : Base.Index?
  
  public mutating func next() -> (Base.Index, Base.Generator.Element)? {
    i?._successorInPlace() ?? {self.i = self.sI}()
    return eG.next().map { (i!, $0) }
  }
  
  private init(g: Base.Generator, i: Base.Index) {
    eG = g
    sI = i
    self.i = nil
  }
}

public struct SpecEnumerateSeq<Base : CollectionType> : LazySequenceType {
  
  private let col: Base
  public func generate() -> SpecEnumerateGen<Base> {
    return SpecEnumerateGen(g: col.generate(), i: col.startIndex)
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


