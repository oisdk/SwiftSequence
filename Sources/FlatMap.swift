extension LazySequenceType {
  
  @warn_unused_result
  public func flatMap<T>(transform: Elements.Generator.Element -> T?)
    -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<Elements, T?>>, T> {
      return self
        .map(transform)
        .filter { opt in opt != nil }
        .map { notNil in notNil! }
  }
}

extension LazyCollectionType {
  
  @warn_unused_result
  public func flatMap<T>(transform: Elements.Generator.Element -> T?)
    -> LazyMapCollection<LazyFilterCollection<LazyMapCollection<Elements, T?>>, T> {
      return self
        .map(transform)
        .filter { opt in opt != nil }
        .map { notNil in notNil! }
  }
}