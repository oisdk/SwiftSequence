import XCTest
@testable import SwiftSequence

class GenericGeneratorsTests: XCTestCase {
  
  func testInc() {
    
    let expectation = 1...100
    
    let reality = (1...).prefix(100)
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
  func testStrideForever() {
    
    var reality = stride(1, by: 10).generate()
    
    for var i = 1; i<1000;i += 10 {
      XCTAssert(reality.next() == i)
    }
  }
  
  func testIterate() {
    
    var reality = iterate(2) { $0 * 2 }.generate()
    
    for var i = 2; i < 10; i *= 2 {
      XCTAssert(reality.next() == i)
    }
  }
}