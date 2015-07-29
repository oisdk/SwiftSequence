import XCTest

class ListExtensionsTests: XCTestCase {
  
  func testChunk() {
    
    let expectation: List<List<Int>> = [[1, 2, 3], [4, 5, 6], [7]]
    
    let reality = List(1...7).chunk(3)

    XCTAssert(expectation.elementsEqual(reality) {$0.elementsEqual($1)})
    
  }
  
  func testWindow() {
    
    let expectation: List<List<Int>> = [[1, 2, 3], [2, 3, 4], [3, 4, 5]]
    
    let reality = List(1...5).window(3)
    
    XCTAssert(expectation.elementsEqual(reality) {$0.elementsEqual($1)})
    
  }
  
  func testSplit() {
    
    let expectation: List<List<Int>> = [[1, 3, 4], [4], [5, 6]]
    
    let reality = List([1, 3, 4, 4, 5, 6]).splitAt {$0 % 2 == 0}
    
    XCTAssert(expectation.elementsEqual(reality) {$0.elementsEqual($1)})
    
  }
  
}