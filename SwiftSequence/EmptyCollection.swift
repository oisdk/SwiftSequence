extension EmptyCollection : ArrayLiteralConvertible {
  public init(arrayLiteral: Element...) {
    precondition(arrayLiteral.isEmpty)
  }
}

public func ~= <C : CollectionType>
  (lhs: EmptyCollection<C.Generator.Element>, rhs: C) -> Bool {
    return rhs.isEmpty
}

public func ~= <T> (lhs: EmptyCollection<T>, rhs: List<T>) -> Bool {
  switch rhs {
  case .Cons: return false
  default:    return true
  }
}