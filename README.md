# SwiftSequence
SwiftSequence is a framework of extensions to `SequenceType`, that provides functional, lightweight methods, similar to Python's itertools.

SwiftSequence adds one new protocol: `LazySequenceType`. This protocol has all of the same requirements as `SequenceType`, but anything that conforms to it is assumed to be lazily evaluated.

Every function and method has both a lazy and an eager version (if possible). When using a method, if the underlying sequence conforms to `LazySequenceType`, the method used will be the lazy version. If the sequence is eager, the eager method will be used.

All sequences returned by lazy methods conform to `LazySequenceType`, and these standard library structs have been made to conform, also:

```swift
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
```

To make an eager sequence lazy, the `lazy()` function can be used:

```swift
lazy([1, 2, 3])
  .hop(1)

// 1, 3
```

And to "thunk" a lazy sequence, (to cause it to be evaluated), the `array()` method can be used:

```swift
lazy([1, 2, 3])
  .hop(1)
  .array()

// [1, 3]
```

SwiftSequence has no dependancies beyond the Swift standard library.
