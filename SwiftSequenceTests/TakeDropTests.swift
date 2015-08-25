import XCTest
@testable import SwiftSequence

class TakeDropTests: XCTestCase {
  
  // MARK: Eager
  
  func testTakeWhile() {
    
    let taken = [1, 2, 3, 4, 5, 1, 2, 3].prefixWhile { $0 < 5 }
    
    let expectation = [1, 2, 3, 4]
    
    XCTAssert(taken == expectation)
    
  }
  
  func testDropwhile() {
    
    let dropped = [1, 2, 3, 4, 5, 1, 2, 3].dropWhile { $0 < 5 }
    
    let expectation = [5, 1, 2, 3]
    
    XCTAssert(dropped == expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyTakeWhile() {
    
    let taken = [1, 2, 3, 4, 5, 1, 2, 3].lazy.prefixWhile { $0 < 5 }
    
    let expectation = [1, 2, 3, 4]
    
    XCTAssert(taken.elementsEqual(expectation))
    
  }
  
  func testLazyDropwhile() {
    
    let dropped = [1, 2, 3, 4, 5, 1, 2, 3].lazy.dropWhile { $0 < 5 }
    
    let expectation = [5, 1, 2, 3]
    
    XCTAssert(dropped.elementsEqual(expectation))
    
  }
}