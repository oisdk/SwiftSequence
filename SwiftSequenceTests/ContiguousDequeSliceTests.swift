import XCTest
@testable import SwiftSequence

class ContiguousDequeSliceTests: XCTestCase {
  
  func testDebugDescription() {
    
    let expectation = "[1, 2, 3 | 4, 5, 6]"
    
    let reality = ContiguousDequeSlice(1...6).debugDescription
    
    XCTAssert(expectation == reality)
    
  }
  
  func testCheck() {
    
    var reality = ContiguousDequeSlice(1...6)
    
    XCTAssert("[1, 2, 3 | 4, 5, 6]" == reality.debugDescription)
    XCTAssert(reality.removeFirst() == 1)
    XCTAssert("[2, 3 | 4, 5, 6]" == reality.debugDescription)
    XCTAssert(reality.removeFirst() == 2)
    XCTAssert("[3 | 4, 5, 6]" == reality.debugDescription)
    XCTAssert(reality.removeFirst() == 3)
    XCTAssert("[4, 5 | 6]" == reality.debugDescription)
    XCTAssert(reality.removeFirst() == 4)
    XCTAssert("[5 | 6]" == reality.debugDescription)
    XCTAssert(reality.isBalanced)
    
  }
  
  func testArrayInit() {
    
    let expectation = [1, 2, 3]
    
    let reality = ContiguousDequeSlice([1, 2, 3])
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)
    
  }
  
  func testArrayLiteralConvertible() {
    
    let expectation = [1, 2, 3]
    
    let reality: ContiguousDequeSlice = [1, 2, 3]
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)
    
  }
  
  func testSequenceType() {
    
    let expectation = [1, 2, 3]
    
    let reality = Array(ContiguousDequeSlice([1, 2, 3]))
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testIndexingRetrieval() {
    
    let expectation = (10...15)
    
    let deque = ContiguousDequeSlice(10...15)
    
    let reality = (0...5).map { deque[$0] }
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testIndexingSetting() {
    
    let expectation = (10...15)
    
    var reality = ContiguousDequeSlice(0...5)
    
    for (index, value) in zip((0...5), expectation) {
      reality[index] = value
    }
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testFirst() {
    
    let expectation = 1
    
    let reality = ContiguousDequeSlice([1, 2, 3]).first
    
    XCTAssert(expectation == reality)
    
  }
  
  func testLast() {
    
    let expectation = 3
    
    let reality = ContiguousDequeSlice([1, 2, 3]).last
    
    XCTAssert(expectation == reality)
    
  }
  
  func testRangeIndexingRetrieval() {
    
    let deque = ContiguousDequeSlice(0...10)
    
    for triplet in (0..<8).map({$0...($0 + 3)}) {
      XCTAssert(deque[triplet].elementsEqual(triplet))
    }
  }
  
  func testRangeIndexingSetting() {
    
    let deque = ContiguousDequeSlice(0...10)
    
    let array = [Int](0...10)
    
    for triplet in (0..<8).map({$0...($0 + 3)}) {
      
      var expectation = array
      
      expectation[triplet] = [0, 0, 0, 0]
      
      var reality = deque
      
      reality[triplet] = [0, 0, 0, 0]
      
      XCTAssert(expectation.elementsEqual(reality))
    }
  }
  
  func testAppend() {
    
    let expectation = 0...11
    
    var reality = ContiguousDequeSlice(0...10)
    
    reality.append(11)
    
    XCTAssert(expectation.elementsEqual(reality))
  }
  
  func testPrepend() {
    
    let expectation = 0...10
    
    var reality = ContiguousDequeSlice(1...10)
    
    reality.prepend(0)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testExtend() {
    
    let expectation = 0...10
    
    var reality = ContiguousDequeSlice(0...5)
    
    reality.extend(6...10)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testPrextend() {
    
    let expectation = 0...10
    
    var reality = ContiguousDequeSlice(6...10)
    
    reality.prextend(0...5)
    
    XCTAssert(expectation.elementsEqual(reality))
  }
  
  func testInsert() {
    
    let array = [Int](0...10)
    
    let deque = ContiguousDequeSlice(array)
    
    for i in array.indices {
      
      var (expectation, reality) = (array, deque)
      
      expectation.insert(100, atIndex: i)
      
      reality.insert(100, atIndex: i)
      
      XCTAssert(expectation.elementsEqual(reality))
      
    }
  }
  
  func testRemoveAll() {
    
    var reality = ContiguousDequeSlice(1...100)
    
    reality.removeAll()
    
    XCTAssert(reality.isEmpty)
    
  }
  
  func testRemoveAtIndex() {
    
    let array = [Int](0...10)
    
    let deque = ContiguousDequeSlice(array)
    
    for i in array.indices {
      
      var (expectation, reality) = (array, deque)
      
      XCTAssert(expectation.removeAtIndex(i) == reality.removeAtIndex(i))
      
      XCTAssert(expectation.elementsEqual(reality))
      
    }
  }
  
  func testReverse() {
    
    let expectation = [5, 4, 3, 2, 1]
    
    let reality = ContiguousDequeSlice(1...5).reverse()
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testDropFirst() {
    
    let expectation = [2, 3, 4, 5]
    
    let reality = ContiguousDequeSlice(1...5).dropFirst()
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)
    
  }
  
  func testDropLast() {
    
    let expectation = [1, 2, 3, 4]
    
    let reality = ContiguousDequeSlice(1...5).dropLast()
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)
    
  }
  
  func testRemoveFirst() {
    
    let expectation = [2, 3, 4, 5]
    
    var reality = ContiguousDequeSlice(1...5)
    
    XCTAssert(reality.removeFirst() == 1)
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)
    
  }
  
  func testRemoveLast() {
    
    let expectation = [1, 2, 3, 4]
    
    var reality = ContiguousDequeSlice(1...5)
    
    XCTAssert(reality.removeLast() == 5)
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)
    
  }
  
  func testMap() {
    
    let expectation = [2, 4, 6]
    
    let reality = ContiguousDequeSlice(1...3).map { $0 * 2 }
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)
    
  }
  
  func testFlatMap() {
    
    let expectation = [2, 3, 4, 5, 6, 7]
    
    let before = ContiguousDequeSlice(1...3)
    
    let reality = before.flatMap { ContiguousDequeSlice([$0 * 2, $0 * 2 + 1]) }
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)
    
  }
  
  func testFlatMapOpt() {
    
    let expectation = [2, 6, 10]
    
    let before = ContiguousDequeSlice(1...5)
    
    let reality = before.flatMap { $0 % 2 == 0 ? nil : $0 * 2 }
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)
    
  }
  
  func testFilter() {
    
    let expectation = [1, 3, 5]
    
    let reality = ContiguousDequeSlice(1...5).filter { $0 % 2 == 1 }
    
    XCTAssert(expectation.elementsEqual(reality))
    
    XCTAssert(reality.isBalanced)
    
  }
}