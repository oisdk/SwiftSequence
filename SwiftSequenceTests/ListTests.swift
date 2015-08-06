import XCTest
@testable import SwiftSequence

class ListTests: XCTestCase {
  
  func testDebugDescription() {
    
    let expectation = "[:1, 2, 3:]"
    
    let reality =
    List.Cons(head: 1, tail: List.Cons(head: 2, tail: List.Cons(head: 3, tail: .Nil)))
      .debugDescription
    
    XCTAssert(expectation == reality)
    
  }
  
  func testOperator() {
    
    let expectation = List.Cons(head: 1, tail: List.Cons(head: 2, tail: List.Cons(head: 3, tail: .Nil)))
    
    let reality: List = 1 |> 2 |> 3 |> .Nil
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testSeqInit() {
    
    let expectation = List.Cons(head: 1, tail: List.Cons(head: 2, tail: List.Cons(head: 3, tail: .Nil)))
    
    let reality = List([1, 2, 3])
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testEmptySeqInit() {
    
    let expectation: List<Int> = .Nil
    
    let reality = List<Int>([])
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testArrayLiteralConvertible() {
    
    let expectation = List.Cons(head: 1, tail: List.Cons(head: 2, tail: List.Cons(head: 3, tail: .Nil)))
    
    let reality: List = [1, 2, 3]
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testEmptyArrayLiteralConvertible() {
    
    let expectation: List<Int> = .Nil
    
    let reality: List<Int> = []
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testSequenceType() {
    
    let expectation = [1, 2, 3]
    
    let reality = Array(List([1, 2, 3]))
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testReplace() {
    
    let expectation: List = [1, 2, 0, 4, 5]
    
    let reality = List([1, 2, 3, 4, 5]).replacedWith(0, atIndex: 2)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testCount() {
    
    let expectation = 5
    
    let reality = List([1, 2, 3, 4, 5]).count
    
    XCTAssert(expectation == reality)
  }
  
  func testSubscriptGet() {
    
    let expectation = 3
    
    let reality = List([1, 2, 3, 4, 5])[2]
    
    XCTAssert(expectation == reality)
    
  }
  
  func testSubscriptSet() {
    
    let expectation = [1, 2, 0, 4, 5]
    
    var reality: List = [1, 2, 3, 4, 5]
    
    reality[2] = 0
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testPrepended() {
    
    let expectation = [0, 1, 2, 3]
    
    let reality = List([1, 2, 3]).prepended(0)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testAppended() {
    
    let expectation = [1, 2, 3, 0]
    
    let reality = List([1, 2, 3]).appended(0)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testExtended() {
    
    let expectation = [1, 2, 3, 0, 1]
    
    let reality = List([1, 2, 3]).extended(Array([0, 1]))
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testDrop() {
    
    let expectation = [3, 4, 5]
    
    let reality = List([1, 2, 3, 4, 5]).drop(2)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testDropAll() {
    
    let expectation: [Int] = []
    
    let reality = List([1, 2, 3, 4, 5]).drop(5)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testTake() {
    
    let expectation = [1, 2, 3]
    
    let reality = List([1, 2, 3, 4, 5]).take(3)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testTakeAll() {
    
    let expectation = [1, 2, 3, 4, 5]
    
    let reality = List([1, 2, 3, 4, 5]).take(7)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testRangeSubscript() {
    
    let expectation = [2, 3, 4]
    
    let reality = List([1, 2, 3, 4, 5])[1..<4]
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testEmpty() {
    
    let empty: List<Int> = []
    
    let nonEmpty: List = [1, 2, 3]
    
    XCTAssert(empty.isEmpty)
    XCTAssert(!nonEmpty.isEmpty)
    
  }
  
  func testFirst() {
    
    let expectation = 1
    
    let reality = List([1, 2, 3]).first
    
    XCTAssert(expectation == reality)
    
  }
  
  func testLast() {
    
    let expectation = 3
    
    let reality = List([1, 2, 3]).last
    
    XCTAssert(expectation == reality)
    
  }
  
  func testMap() {
    
    let expectation = [2, 4, 6]
    
    let reality = List([1, 2, 3]).map { $0 * 2 }
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testFlatMap() {
    
    let expectation = [2, 3, 4, 5, 6, 7]
    
    let reality = List([1, 2, 3]).flatMap { Array([$0 * 2, $0 * 2 + 1]) }
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testFlatMapList() {
    
    let expectation = [2, 3, 4, 5, 6, 7]
    
    let reality = List([1, 2, 3]).flatMap { List([$0 * 2, $0 * 2 + 1]) }
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testFlatMapOpt() {
    
    let expectation = [1, 3]
    
    let reality = List([1, 2, 3]).flatMap { $0 % 2 == 0 ? nil : $0 }
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testTail() {
    
    let expectation = [2, 3]
    
    let reality = List([1, 2, 3]).tail
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testRemoveFirst() {
    
    let expectation = [2, 3]
    
    var reality = List([1, 2, 3])
    
    XCTAssert(reality.removeFirst() == 1)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testFilter() {
    
    let expectation = [2, 4, 6, 8]
    
    let reality = List(1..<9).filter { $0 % 2 == 0 }
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testReverse() {
    
    let expectation = [5, 4, 3, 2, 1]
    
    let reality = List(1...5).reverse()
    
    XCTAssert(expectation.elementsEqual(reality))
  }
  
}