import XCTest
@testable import SwiftSequence

class ListExtensionsTests: XCTestCase {
  
  func testChunk() {
    
    let expectation: List<List<Int>> = [[1, 2, 3], [4, 5, 6], [7]]
    
    let reality = List(1...7).chunk(3)

    XCTAssert(expectation.elementsEqual(reality) {$0.elementsEqual($1)})
    
  }
  
  func testWindow() {
    
    let expectation: List<List<Int>> = [[1, 2, 3], [2, 3, 4], [3, 4, 5]]
    
    let reality = List(1...5).window(3)
    
    XCTAssert(expectation.elementsEqual(reality) {$0.elementsEqual($1)})
    
  }
  
  func testSplit() {
    
    let expectation: List<List<Int>> = [[1, 3, 4], [4], [5, 6]]
    
    let reality = List([1, 3, 4, 4, 5, 6]).splitAt {$0 % 2 == 0}
    
    XCTAssert(expectation.elementsEqual(reality) {$0.elementsEqual($1)})
    
  }
  
  func textCycleN() {
    
    let expectation: List = [1, 2, 3, 1, 2, 3, 1, 2, 3]
    
    let reality = List(1...3).cycle(3)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testCycle() {
    
    var reality = List([1, 2]).cycle().generate()
    
    for _ in 0..<100 {
      XCTAssert(reality.next() == 1)
      XCTAssert(reality.next() == 2)
    }
  }
  
  func testHop() {
    
    let expectation: List = [1, 3, 5, 7, 9]
    
    let reality = List(1...9).hop(2)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testInterpose() {
    
    let expectation = [1, 0, 2, 0, 3, 0, 4, 0, 5]
    
    let reality = List(1...5).interpose(0)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testInterposeList()  {
    
    let expectation = [1, 0, 0, 2, 0, 0, 3, 0, 0, 4, 0, 0, 5]
    
    let reality = List(1...5).interpose(List([0, 0]))
    
    XCTAssert(expectation.elementsEqual(reality))

  }
  
  func testInterDig() {
    
    let expectation: List = [1, 10, 2, 20, 3, 30, 4, 40, 5, 50]
    
    let reality = interdig(List(1...5), List(1...5).map { $0 * 10 })
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testScan() {
    
    let expectation: List = [1, 3, 6, 10, 15]
    
    let reality = List(1...5).scan(0, combine: +)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testScan1() {
    
    let expectation: List = [3, 6, 10, 15]
    
    let reality = List(1...5).scan(+)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testTakeWhile() {
    
    let expectation = List([1, 2, 3, 4])
    
    let reality = List([1, 2, 3, 4, 5, 3, 2, 1]).takeWhile { $0 < 5 }
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testDropWhile() {
    
    let expectation: List = [4, 5, 2]
    
    let reality = List([1, 2, 3, 4, 5, 2]).dropWhile { $0 < 4 }
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testZip() {
    
    let expectation = [(1, 1), (2, 2), (3, 3)]
    
    let reality = zip(List(1...3), List(1...10))

    XCTAssert(expectation.elementsEqual(reality) { $0.0 == $1.0 && $0.1 == $1.1 })
    
  }
  
  func testZipWithPadding() {
    
    let expectation = [(1, 1), (2, 2), (3, 3), (4, 0), (5, 0)]
    
    let reality = zip(List(1...5), List(1...3), pad0: 0, pad1: 0)
    
    XCTAssert(expectation.elementsEqual(reality) { $0.0 == $1.0 && $0.1 == $1.1 })
    
  }
}
