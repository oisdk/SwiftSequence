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
    
    let interposed = lazy([1, 2, 3]).interpose(10)
    
    let expectation = lazy([1, 10, 2, 10, 3, 10])
    
    XCTAssert(interposed.elementsEqual(expectation))
    
    let _ = interposed.array()
    
  }
  
  func testLazyInterposeMultiple() {
    
    let interposed = lazy([1, 2, 3, 4, 5]).interpose(10, n: 2)
    
    let expectation = lazy([1, 2, 10, 3, 4, 10, 5])
    
    XCTAssert(interposed.elementsEqual(expectation))
    
    let _ = interposed.array()
    
  }
  
  func testLazyInterposeColSingle() {
    
    let interposed = lazy([1, 2, 3]).interpose([10, 20])
    
    let expectation = [1, 10, 20, 2, 10, 20, 3, 10, 20]
    
    XCTAssert(interposed.elementsEqual(expectation))
    
    let _ = interposed.array()
    
  }
  
  func testLazyInterposeColMultiple() {
    
    let interposed = lazy([1, 2, 3, 4, 5]).interpose([10, 20], n: 2)
    
    let expectation = [1, 2, 10, 20, 3, 4, 10, 20, 5]
    
    XCTAssert(interposed.elementsEqual(expectation))
    
    let _ = interposed.array()
    
  }
  
  func testLazyInterdigitate() {
    
    let interdigged = interdig(lazy([1, 2, 3]), lazy([10, 20, 30]))
    
    let expectation = [1, 10, 2, 20, 3, 30]
    
    XCTAssert(interdigged.elementsEqual(expectation))
    
    let _ = interdigged.array()
    
  }
  
  func testLazyInterdigitateMultiple() {
    
    let interdigged = interdig(lazy([1, 2, 3, 4, 5]), lazy([10, 20, 30, 40, 50, 60]), s0Len: 2, s1Len: 3)
    
    let expectation = [1, 2, 10, 20, 30, 3, 4, 40, 50, 60, 5]
    
    XCTAssert(interdigged.elementsEqual(expectation))
    
    let _ = interdigged.array()
    
  }
}