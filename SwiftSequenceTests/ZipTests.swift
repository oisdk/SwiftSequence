import XCTest
@testable import SwiftSequence

class ZipTests: XCTestCase {
  
  func testWithNilPadding() {
    
    let zipped = zipWithPadding([1, 2, 3], [1, 2])
    
    let expectation: Array<(Int?, Int?)> = [ (1, 1), (2, 2), (3, nil) ]
    
    XCTAssert(zipped.elementsEqual(
      expectation,
      isEquivalent: { $0.0 == $1.0 && $0.1 == $1.1 }
      )
    )
    
    let _ = zipped.array()
    
  }
  
  func testZipWithCustomPadding() {
    
    let zipped = zipWithPadding([1, 2, 3], [1, 2], pad0: 10, pad1: 20)
    
    let expectation = [(1, 1), (2, 2), (3, 20)]
    
    XCTAssert(zipped.elementsEqual(
      expectation,
      isEquivalent: { $0.0 == $1.0 && $0.1 == $1.1 }
      )
    )
    
    let _ = zipped.array()
    
  }
}