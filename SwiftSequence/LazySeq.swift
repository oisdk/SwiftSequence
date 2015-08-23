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

public extension LazySequenceType {
  func array() -> [Generator.Element] {
    return Array(self)
  }
}
