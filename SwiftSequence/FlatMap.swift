/**
A lazy implementation of flatMap(). The standard library flatMap() had a new behaviour
in Swift 2.0: when it's used over a sequence, and the "transform" closure returns an
optional, it returns an array of the result of transform, unwrapped, with anything that
evaluates to nil removed. Since there's already a lazy implemtation of map() and filter(),
the missing lazy flatMap() seemed to be a gap. The two functions here behave the same as
the eager flatMap(), except they return LazySequenceType.
*/

// MARK: flatMap for nested sequences

public struct FlatMapGen<G : GeneratorType, S : SequenceType> : GeneratorType {
  
  private let transform: G.Element -> S
  private var g : G
  private var innerGen : S.Generator?
  
  public mutating func next() -> S.Generator.Element? {
    for ; innerGen != nil; innerGen = g.next().map(transform)?.generate() {
      if let next = innerGen?.next() {
        return next
      }
    }
    return nil
  }
  private init(transform: G.Element -> S, var g: G) {
    self.transform = transform
    self.innerGen = g.next().map(transform)?.generate()
    self.g = g
  }

//  Recursive version:
//
//  public mutating func next() -> S.Generator.Element? {
//    return innerGen?.next() ?? {
//      g.next().flatMap {
//        innerGen = transform($0).generate()
//        return next()
//      }
//    }()
//  }
//  (this version has no custom init: innerGen should be initialised to nil)
}

public struct FlatMapSeq<S0 : SequenceType, S1 : SequenceType> : LazySequenceType {
  
  private let seq: S0
  private let transform: S0.Generator.Element -> S1
  
  public func generate() -> FlatMapGen<S0.Generator, S1> {
    return FlatMapGen(transform: transform, g: seq.generate())
  }
  
}

public extension LazySequenceType {
  /// Lazy `flatMap()`
  /// - SeeAlso: `flatMap()`
  
  func flatMap<S : SequenceType>
    (transform: (Generator.Element) -> S) -> FlatMapSeq<Self, S> {
      return FlatMapSeq(seq: self, transform: transform)
  }
}

// MARK: flatMap for optionals

public struct FlatMapOptGen<G : GeneratorType, T> : GeneratorType {
  
  private let transform: G.Element -> T?
  private var g : G
  
  mutating public func next() -> T? {
    
    while let next = g.next() {
      if let ret = transform(next) {
        return ret
      }
    }
    return nil
    
//    Recursive version:
//
//    return g.next().flatMap { transform($0) ?? next() }
  }
}

public struct FlatMapOptSeq<S : SequenceType, T> : LazySequenceType {
  
  private let seq: S
  private let transform: S.Generator.Element -> T?
  
  public func generate() -> FlatMapOptGen<S.Generator, T> {
    return FlatMapOptGen(transform: transform, g: seq.generate())
  }
}

public extension LazySequenceType {
  
  /// Lazy `flatMap()`
  /// - SeeAlso: `flatMap()`
  
  func flatMap<T>(transform: (Self.Generator.Element) -> T?) -> FlatMapOptSeq<Self, T> {
    return FlatMapOptSeq(seq: self, transform: transform)
  }
}
