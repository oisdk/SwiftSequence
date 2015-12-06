public struct RandomAccessHopCollection<
  Base: CollectionType where
  Base.Index : RandomAccessIndexType,
  Base.Index.Distance : ForwardIndexType
  >: CollectionType {
  
  private let base: Base
  private let by  : Base.Index.Stride
  private let fac : Base.Index.Distance
  
  public let startIndex: Base.Index.Distance
  public let endIndex: Base.Index.Distance
  
  public typealias SubSequence = RandomAccessHopCollection<Base>
  
  public subscript(i: Base.Index.Distance) -> Base.Generator.Element {
    return base[base.startIndex.advancedBy(fac * i)]
  }
  
  public func generate() -> IndexingGenerator<RandomAccessHopCollection<Base>> {
    return IndexingGenerator(self)
  }
  
  private init(_ b: Base, _ by: Base.Index.Stride) {
    base = b
    self.by = by
    fac = base.startIndex.distanceTo(base.startIndex.advancedBy(by))
    if base.isEmpty { endIndex = 0 }
    else { endIndex = (base.startIndex.distanceTo(base.endIndex.predecessor()) / fac).successor() }
    startIndex = 0
  }
  
  private init(_ b: Base, _ by: Base.Index.Stride, from: Base.Index.Distance, to: Base.Index.Distance) {
    base = b
    self.by = by
    fac = base.startIndex.distanceTo(base.startIndex.advancedBy(by))
    startIndex = from
    endIndex = to
  }
  
  public subscript(r: Range<Base.Index.Distance>) -> RandomAccessHopCollection<Base> {
    return RandomAccessHopCollection(base, by, from: r.startIndex, to: r.endIndex)
  }
}

extension CollectionType where Index: RandomAccessIndexType, Index.Distance: ForwardIndexType {
  public subscript(by by: Index.Stride) -> RandomAccessHopCollection<Self> {
    return RandomAccessHopCollection(self, by)
  }
}

extension RandomAccessHopCollection: CustomStringConvertible, CustomDebugStringConvertible {
  public var debugDescription: String {
    return Array(self).debugDescription
  }
  public var description: String {
    return String(Array(self))
  }
}

public extension CollectionType where
  SubSequence: CollectionType,
  Index == SubSequence.Index,
  SubSequence.Index: RandomAccessIndexType,
  SubSequence.Index.Distance: ForwardIndexType {
  subscript(r: Range<Index>, by by: Index.Stride) -> RandomAccessHopCollection<SubSequence> {
    return self[r][by: by]
  }
  subscript(r: OpenEndedRange<Index>, by by: Index.Stride) -> RandomAccessHopCollection<SubSequence> {
    return suffixFrom(r.val)[by: by]
  }
  subscript(r: OpenStartedRangeTo<Index>, by by: Index.Stride) -> RandomAccessHopCollection<SubSequence> {
    return prefixUpTo(r.val)[by: by]
  }
  subscript(r: OpenStartedRangeThrough<Index>, by by: Index.Stride) -> RandomAccessHopCollection<SubSequence> {
    return prefixThrough(r.val)[by: by]
  }
}