import XCTest
@testable import SwiftSequence

class InterposeTests: XCTestCase {
  
  // MARK: Eager
  
  func testInterposeSingle() {
    
    let interposed = [1, 2, 3].interpose(10)
    
    let expectation = [1, 10, 2, 10, 3]
    
    XCTAssert(interposed == expectation)
    
  }
  
  func testInterposeMultiple() {
    
    let interposed = [1, 2, 3, 4, 5].interpose(10, n: 2)
    
    let expectation = [1, 2, 10, 3, 4, 10, 5]
    
    XCTAssert(interposed == expectation)
    
  }
  
  func testInterposeColSingle() {
    
    let interposed = [1, 2, 3].interpose([10, 20])
    
    let expectation = [1, 10, 20, 2, 10, 20, 3]
    
    XCTAssert(interposed == expectation)
    
  }
  
  func testInterposeColMultiple() {
    
    let interposed = [1, 2, 3, 4, 5].interpose([10, 20], n: 2)
    
    let expectation = [1, 2, 10, 20, 3, 4, 10, 20, 5]
    
    XCTAssert(interposed == expectation)
    
  }
  
  func testInterdigitate() {
    
    let interdigged = interdig([1, 2, 3], [10, 20, 30])
    
    let expectation = [1, 10, 2, 20, 3, 30]
    
    XCTAssert(interdigged == expectation)
    
  }
  
  func testInterdigitateMultiple() {
    
    let interdigged = interdig([1, 2, 3, 4, 5], [10, 20, 30, 40, 50, 60], s0Len: 2, s1Len: 3)
    
    let expectation = [1, 2, 10, 20, 30, 3, 4, 40, 50, 60, 5]
    
    XCTAssert(interdigged == expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyInterposeSingle() {
    
    let interposed = [1, 2, 3].lazy.interpose(10)
    
    let expectation = [1, 10, 2, 10, 3, 10].lazy
    
    XCTAssert(interposed.elementsEqual(expectation))
    
  }
  
  func testLazyInterposeMultiple() {
    
    let interposed = [1, 2, 3, 4, 5].lazy.interpose(10, n: 2)
    
    let expectation = [1, 2, 10, 3, 4, 10, 5].lazy
    
    XCTAssert(interposed.elementsEqual(expectation))
    
  }
  
  func testLazyInterposeColSingle() {
    
    let interposed = [1, 2, 3].lazy.interpose([10, 20])
    
    let expectation = [1, 10, 20, 2, 10, 20, 3, 10, 20]
    
    XCTAssert(interposed.elementsEqual(expectation))
    
  }
  
  func testLazyInterposeColMultiple() {
    
    let interposed = [1, 2, 3, 4, 5].lazy.interpose([10, 20], n: 2)
    
    let expectation = [1, 2, 10, 20, 3, 4, 10, 20, 5]
    
    XCTAssert(interposed.elementsEqual(expectation))
    
  }
  
  func testLazyInterdigitate() {
    
    let interdigged = interdig([1, 2, 3].lazy, [10, 20, 30].lazy)
    
    let expectation = [1, 10, 2, 20, 3, 30]
    
    XCTAssert(interdigged.elementsEqual(expectation))
    
  }
  
  func testLazyInterdigitateMultiple() {
    
    let interdigged = interdig([1, 2, 3, 4, 5].lazy, [10, 20, 30, 40, 50, 60].lazy, s0Len: 2, s1Len: 3)
    
    let expectation = [1, 2, 10, 20, 30, 3, 4, 40, 50, 60, 5]
    
    XCTAssert(interdigged.elementsEqual(expectation))
    
  }
}