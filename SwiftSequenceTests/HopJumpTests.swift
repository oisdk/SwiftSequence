import XCTest
@testable import SwiftSequence

class HopJumpTests: XCTestCase {
  
  // MARK: Eager
  
  func testHop() {
    
    let toHop = [1, 2, 3, 4, 5, 6]
    
    XCTAssert(toHop.hop(3) == [1, 4])
    XCTAssert(toHop.hop(2) == [1, 3, 5])
    XCTAssert(toHop.hop(1) == toHop)
    
  }
  
  // MARK: Lazy
  
  func testLazyHop() {
    
    let toHop = [1, 2, 3, 4, 5, 6].lazy
    
    XCTAssert(toHop.hop(3).elementsEqual([1, 4]))
    XCTAssert(toHop.hop(2).elementsEqual([1, 3, 5]))
    XCTAssert(toHop.hop(1).elementsEqual(toHop))
    
    let _ = Array(toHop.hop(1))
    
  }
}