import XCTest

class DequeTests: XCTestCase {
  
  func testDebugDescription() {
    
    let expectation = "1, 2, 3 | 4, 5, 6"
    
    let reality = Deque(1...6).debugDescription

    XCTAssert(expectation == reality)
    
  }
  
  func testCheck() {
    
    var reality = Deque(1...6)
    
    XCTAssert("1, 2, 3 | 4, 5, 6" == reality.debugDescription)
    XCTAssert(reality.removeFirst() == 1)
    XCTAssert("2, 3 | 4, 5, 6" == reality.debugDescription)
    XCTAssert(reality.removeFirst() == 2)
    XCTAssert("3 | 4, 5, 6" == reality.debugDescription)
    XCTAssert(reality.removeFirst() == 3)
    XCTAssert("4, 5 | 6" == reality.debugDescription)
    XCTAssert(reality.removeFirst() == 4)
    XCTAssert("5 | 6" == reality.debugDescription)
    XCTAssert(reality.isBalanced)
    
  }
  
  func testArrayInit() {
    
    let expectation = [1, 2, 3]
    
    let reality = Deque(array: [1, 2, 3])
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)
    
  }
  
  func testArrayLiteralConvertible() {
    
    let expectation = [1, 2, 3]
    
    let reality: Deque = [1, 2, 3]
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)

  }
  
  func testSequenceType() {
    
    let expectation = [1, 2, 3]
    
    let reality = Array(Deque([1, 2, 3]))
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testFirst() {
    
    let expectation = 1
    
    let reality = Deque([1, 2, 3]).first
    
    XCTAssert(expectation == reality)
    
  }
  
  func testLast() {
    
    let expectation = 3
    
    let reality = Deque([1, 2, 3]).last
    
    XCTAssert(expectation == reality)
    
  }
  
  func testReverse() {
    
    let expectation = [5, 4, 3, 2, 1]
    
    let reality = Deque(1...5).reverse()
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testTail() {
    
    let expectation = [2, 3, 4, 5]
    
    let reality = Deque(1...5).tail
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)

  }
  
  func testInitial() {
    
    let expectation = [1, 2, 3, 4]
    
    let reality = Deque(1...5).initial
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)

  }
  
  func testDropFirst() {
    
    let expectation = [2, 3, 4, 5]
    
    let reality = dropFirst(Deque(1...5))
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)

  }
  
  func testDropLast() {
    
    let expectation = [1, 2, 3, 4]
    
    let reality = dropLast(Deque(1...5))
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)

  }
  
  func testRemoveFirst() {
    
    let expectation = [2, 3, 4, 5]
    
    var reality = Deque(1...5)
    
    XCTAssert(reality.removeFirst() == 1)
  
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)

  }
  
  func testRemoveLast() {
    
    let expectation = [1, 2, 3, 4]
    
    var reality = Deque(1...5)
    
    XCTAssert(reality.removeLast() == 5)
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)

  }
  
  func testMap() {
    
    let expectation = [2, 4, 6]
    
    let reality = Deque(1...3).map { $0 * 2 }
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)

  }
  
  func testFlatMap() {
    
    let expectation = [2, 3, 4, 5, 6, 7]
    
    let before = Deque(1...3)
    
    let reality = before.flatMap { Deque([$0 * 2, $0 * 2 + 1]) }
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)

  }
  
  func testFlatMapOpt() {
    
    let expectation = [2, 6, 10]
    
    let before = Deque(1...5)
    
    let reality = before.flatMap { $0 % 2 == 0 ? nil : $0 * 2 }
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)

  }
  
  func testFilter() {
    
    let expectation = [1, 3, 5]
    
    let reality = Deque(1...5).filter { $0 % 2 == 1 }
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)

  }
}