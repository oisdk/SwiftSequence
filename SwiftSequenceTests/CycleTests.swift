import XCTest
@testable import SwiftSequence

class CycleTests: XCTestCase {
  
  // MARK: Eager
  
  func testCylceN() {
    
    let cycled = [1, 2, 3].cycle(2)
    
    let expectation = [1, 2, 3, 1, 2, 3]
    
    XCTAssert(cycled.elementsEqual(expectation, isEquivalent: ==))
    
  }
  
  // MARK: Lazy
  
  func testLazyCycleN() {
    
    let cycled = [1, 2, 3].lazy.cycle(2)
    
    let expectation = [1, 2, 3, 1, 2, 3].lazy
    
    XCTAssert(cycled.elementsEqual(expectation, isEquivalent: ==))
    
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