// MARK: Categorise
// MARK: ChunkWindowSplit
extension List {
  private func split(n: Int) -> (List<Element>, List<Element>) {
    switch (n, self) {
    case (0, _), (_, .Nil): return (.Nil, self)
    case (_, let .Cons(head, tail)): return {(head |> $0.0, $0.1)}(tail.split(n - 1))
    }
  }
  public func chunk(n: Int) -> List<List<Element>> {
    switch self {
    case .Nil: return .Nil
    case .Cons: return {$0.0 |> $0.1.chunk(n)}(split(n))
    }
  }
}

extension List {
  public func window(n: Int) -> List<List<Element>> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(_, tail): return take(n) |> tail.window(n)
    }
  }
}

extension List {
  private func split(@noescape isSplit: Element -> Bool) -> (List<Element>, List<Element>) {
    switch self {
    case .Nil: return (.Nil, self)
    case let .Cons(head, tail):
      return isSplit(head) ? (.Nil, self) :
        {(head |> $0.0, $0.1)}(tail.split(isSplit))
    }
  }
  public func splitAt(@noescape isSplit: Element -> Bool) -> List<List<Element>> {
    switch self {
    case .Nil:  return .Nil
    case .Cons: return { $0.0 |> $0.1.splitAt(isSplit) }(split(isSplit))
    }
  }
}
// MARK: Combinations
// MARK: Cycle
extension List {
  public func cycle() -> LazyList<Element> {
    return LazyList(self).cycle()
  }
}

extension List {
  public func cycle(n: Int) -> List<Element> {
    return List<Int>(0..<n).flatMap { _ in self }
  }
}
// MARK: Enumerate
// MARK: Finding
// MARK: HopJump
public extension List {
  public func hop(n: Int, i: Int = 0) -> List<Element> {
    switch (i, self) {
    case (0, let .Cons(head, tail)): return head |> tail.hop(n, i: n)
    case (_, .Cons(_, let tail)): return tail.hop(n, i: i - 1)
    case (_, .Nil): return .Nil
    }
  }
}
// MARK: Interpose
extension List {
  private func prependtoAll(with: Element) -> List<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return with |> head |> tail.prependtoAll(with)
    }
  }
}

extension List {
  public func interpose(element: Element) -> List<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return head |> tail.prependtoAll(element)
    }
  }
}

extension List {
  private func prependtoAll(with: List<Element>) -> List<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return with.extended(head |> tail.prependtoAll(with))
    }
  }
}

extension List {
  public func interpose(with: List<Element>) -> List<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return head |> tail.prependtoAll(with)
    }
  }
}

public func interdig<T>(s0: List<T>, _ s1: List<T>) -> List<T> {
  switch (s0, s1) {
  case let (.Cons(h0, t0), .Cons(h1, t1)): return h0 |> h1 |> interdig(t0, t1)
  case let(.Cons(h0, _), _): return h0 |> .Nil
  default: return .Nil
  }
}

// MARK: NestedSequences
// MARK: Permutations
// MARK: ScanReduce
extension List {
  public func scan<T>(initial: T, @noescape combine: (accumulator: T, element: Element) -> T) -> List<T> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail):
      let tHead = combine(accumulator: initial, element: head)
      return tHead |> tail.scan(tHead, combine: combine)
    }
  }
  public func scan(@noescape combine: (accumulator: Element, element: Element) -> Element) -> List<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return tail.scan(head, combine: combine)
    }
  }
}
// MARK: TakeDrop
extension List {
  public func takeWhile(@noescape condition: Element -> Bool) -> List<Element> {
    switch self {
    case .Nil: return self
    case let .Cons(head, tail):
      return condition(head) ? (head |> tail.takeWhile(condition)) : .Nil
    }
  }
  public func dropWhile(@noescape condition: Element -> Bool) -> List<Element> {
    switch self {
    case .Nil: return self
    case let .Cons(head, tail):
      return condition(head) ? tail.dropWhile(condition) : (head |> tail)
    }
  }
}
// MARK: Zip
public func zip<A, B>(s0: List<A>, _ s1: List<B>) -> List<(A, B)> {
  switch (s0, s1) {
  case let (.Cons(h0, t0), .Cons(h1, t1)): return (h0, h1) |> zip(t0, t1)
  default: return .Nil
  }
}
public func zip<A, B>(s0: List<A>, _ s1: List<B>, pad0: A, pad1: B) -> List<(A, B)> {
  switch (s0, s1) {
  case let (.Cons(h0, t0), .Cons(h1, t1)): return (h0, h1) |> zip(t0, t1, pad0: pad0, pad1: pad1)
  case let (.Cons(h0, t0), .Nil): return (h0, pad1) |> zip(t0, .Nil, pad0: pad0, pad1: pad1)
  case let (.Nil, .Cons(h1, t1)): return (pad0, h1) |> zip(.Nil, t1, pad0: pad0, pad1: pad1)
  default: return .Nil
  }
}