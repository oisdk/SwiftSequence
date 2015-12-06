public struct FlatMapOptionalGenerator<G: GeneratorType, Element>: GeneratorType {
  private let transform: G.Element -> Element?
  private var generator: G
  public mutating func next() -> Element? {
    while let next = generator.next() {
      if let transformed = transform(next) {
        return transformed
      }
    }
    return nil
  }
}

public struct FlatMapOptionalSequence<S: LazySequenceType, Element>: LazySequenceType {
  private let transform: S.Generator.Element -> Element?
  private let sequence: S
  public func generate() -> FlatMapOptionalGenerator<S.Generator, Element> {
    return FlatMapOptionalGenerator(transform: transform, generator: sequence.generate())
  }
}

extension LazySequenceType {
  public func flatMap<T>(transform: Generator.Element -> T?) -> FlatMapOptionalSequence<Self, T> {
    return FlatMapOptionalSequence(transform: transform, sequence: self)
  }
}