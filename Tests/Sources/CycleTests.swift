import XCTest
import SwiftSequence

class CycleTests: XCTestCase {
  
  var allTests : [(String, () -> ())] {
    return [
      ("testCylceN", testCylceN),
      ("testLazyCycleN", testLazyCycleN),
      ("testLazyCycle", testLazyCycle)
    ]
  }
  
  // MARK: Eager
  
  func testCylceN() {
    
    let cycled = [1, 2, 3].cycle(2)
    
    let expectation = [1, 2, 3, 1, 2, 3]
    
    XCTAssertEqual(cycled, expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyCycleN() {
    
    let cycled = [1, 2, 3].lazy.cycle(2)
    
    let expectation = [1, 2, 3, 1, 2, 3]
    
    XCTAssertEqualSeq(cycled, expectation)
    
  }
  
  func testLazyCycle() {
    
    var cycled = [1, 2].cycle()
    
    XCTAssert(cycled.next() == 1)
    XCTAssert(cycled.next() == 2)
    XCTAssert(cycled.next() == 1)
    XCTAssert(cycled.next() == 2)
    XCTAssert(cycled.next() == 1)
    XCTAssert(cycled.next() == 2)
    XCTAssert(cycled.next() == 1)
    XCTAssert(cycled.next() == 2)
    XCTAssert(cycled.next() == 1)
    XCTAssert(cycled.next() == 2)
    XCTAssert(cycled.next() == 1)
    XCTAssert(cycled.next() == 2)
    XCTAssert(cycled.next() == 1)
    XCTAssert(cycled.next() == 2)
  }

}