import XCTest

class EnumerateTests: XCTestCase {
  func testEnumerate() {
    
    let word = "hello".characters
    
    for (index, letter) in word.specEnumerate() {
      
      XCTAssert(word[index] == letter)
      
    }
  }
}