public protocol LazySequenceType : SequenceType {}


public extension LazySequenceType {
  func map<T>(transform: (Generator.Element) -> T)
    -> LazySequence<MapSequence<Self, T>>  {
      return lazy(self).map(transform)
  }
  
  func filter(includeElement: (Generator.Element) -> Bool)
    -> LazySequence<FilterSequence<Self>> {
      return lazy(self).filter(includeElement)
  }
}

extension LazySequence                : LazySequenceType {}
extension LazyForwardCollection       : LazySequenceType {}
extension LazyBidirectionalCollection : LazySequenceType {}
extension LazyRandomAccessCollection  : LazySequenceType {}
extension FilterSequence              : LazySequenceType {}
extension FilterCollection            : LazySequenceType {}
extension MapSequence                 : LazySequenceType {}
extension MapCollection               : LazySequenceType {}
extension Zip2Sequence                : LazySequenceType {}
extension EnumerateSequence           : LazySequenceType {}

public extension LazySequenceType {
  func array() -> [Generator.Element] {
    return Array(self)
  }
}
