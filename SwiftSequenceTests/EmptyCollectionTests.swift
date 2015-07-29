import XCTest

class EmptyCollectionTests: XCTestCase {
  
  func testInit() {
    
    let _: EmptyCollection<Int> = []
    
  }
  
  func testMatchEmpty() {
    
    let emptyArray: [Int] = []
    
    switch emptyArray {
    case []: XCTAssert(true)
    default: XCTAssert(false)
    }
    
  }
  
  func testMatchNonEmpty() {
    
    let array = [1, 2, 3]
    
    switch array {
    case []: XCTAssert(false)
    default: XCTAssert(true)
    }
    
  }
  
}