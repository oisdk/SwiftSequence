public protocol LazySequenceType : SequenceType {
  typealias S : SequenceType
  func filter(includeElement: (S.Generator.Element) -> Bool)
    -> LazySequence<FilterSequenceView<S>>
}

public extension LazySequenceType {
  func map<T>(transform: (Self.Generator.Element) -> T)
    -> LazySequence<MapSequenceView<Self, T>>  {
      return lazy(self).map(transform)
  }
  
  func filter(includeElement: (Self.Generator.Element) -> Bool)
    -> LazySequence<FilterSequenceView<Self>> {
      return lazy(self).filter(includeElement)
  }
}

extension LazySequence                : LazySequenceType {}
extension LazyForwardCollection       : LazySequenceType {}
extension LazyBidirectionalCollection : LazySequenceType {}
extension LazyRandomAccessCollection  : LazySequenceType {}
extension FilterSequenceView          : LazySequenceType {}
extension FilterCollectionView        : LazySequenceType {}
extension MapSequenceView             : LazySequenceType {}
extension MapCollectionView           : LazySequenceType {}
extension Zip2                        : LazySequenceType {}
extension EnumerateSequence           : LazySequenceType {}

public extension LazySequenceType {
  func array() -> [Generator.Element] {
    return Array(self)
  }
}
