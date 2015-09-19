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
    
    let chunkd = [1, 2, 3, 4, 5].lazy.chunk(2)
    
    let expectation = [[1, 2], [3, 4], [5]].lazy
    
    XCTAssert(chunkd.elementsEqual(expectation, isEquivalent: ==))
    
  }
  
  func testLazyWindow() {
    
    let expectation = [Int](1...10).window(3)
    
    let reality = [Int](1...10).lazy.window(3)
    
    XCTAssert(expectation.elementsEqual(reality, isEquivalent: ==))
    
  }

}