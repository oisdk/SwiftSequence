public struct IterateGenerator<Element>: GeneratorType {
  private var x: Element
  private let f: Element -> Element
  public mutating func next() -> Element? {
    defer { x = f(x) }
    return x
  }
}

public struct IterateSequence<Element>: SequenceType {
  private let x: Element
  private let f: Element -> Element
  public func generate() -> IterateGenerator<Element> {
    return IterateGenerator(x: x, f: f)
  }
}

public struct IterateEndGenerator<Element>: GeneratorType {
  private var x: Element?
  private var f: Element -> Element?
  public mutating func next() -> Element? {
    guard let y = x else { return nil }
    defer { x = f(y) }
    return y
  }
}

public struct IterateEndSequence<Element>: SequenceType {
  private let x: Element
  private let f: Element -> Element?
  public func generate() -> IterateEndGenerator<Element> {
    return IterateEndGenerator(x: x, f: f)
  }
}