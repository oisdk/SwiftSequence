extension EmptyCollection : ArrayLiteralConvertible {
  public init(arrayLiteral: Element...) {
    precondition(arrayLiteral.isEmpty)
  }
}

public func ~= <C : CollectionType>
  (lhs: EmptyCollection<C.Generator.Element>, rhs: C) -> Bool {
    return rhs.isEmpty
}
