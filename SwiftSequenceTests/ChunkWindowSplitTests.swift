import XCTest
@testable import SwiftSequence

class ChunkWindowSplitTests: XCTestCase {
  // MARK: Eager
  
  func testChunk() {
    
    let chunkd = [1, 2, 3, 4, 5].chunk(2)
    
    let expectation = [[1, 2], [3, 4], [5]]
    
    XCTAssert(chunkd == expectation)
    
  }
  
  func testWindow() {
    
    let windowed = [1, 2, 3, 4, 5].window(3)
    
    let expectation = [[1, 2, 3], [2, 3, 4], [3, 4, 5]]
    
    XCTAssert(windowed == expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyChunk() {
    
    let chunkd = lazy([1, 2, 3, 4, 5]).chunk(2)
    
    let expectation = lazy([[1, 2], [3, 4], [5]])
    
    XCTAssert(chunkd.elementsEqual(expectation, isEquivalent: ==))
    
    let _ = chunkd.array()
    
  }

}