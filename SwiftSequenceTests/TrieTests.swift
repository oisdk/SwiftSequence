import XCTest

class TrieTests: XCTestCase {
  
  func testDebugString() {
    
    let expectation = "123, 345, 234"
    
    let reality = Trie([[1, 2, 3], [3, 4, 5], [2, 3, 4]]).debugDescription
    
    let realitySort = reality.characters.splitAt{ $0 == " " }.map(String.init).map{
      $0.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " ,"))
      }.sort()
    
    let expectationSort = expectation.characters.splitAt{ $0 == " " }.map(String.init).map{
      $0.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " ,"))
      }.sort()
    
    XCTAssert(expectationSort == realitySort)
    
  }
  
  func testEquatable() {
    
    let first  = Trie([[1, 2, 3], [3, 4, 5], [2, 3, 4]])
    let second = Trie([[3, 4, 5], [2, 3, 4], [1, 2, 3]])
    
    XCTAssert(first == second)
    
  }
  
  func testInsert() {
    
    let expectation = Trie([[1, 2, 3], [3, 4, 5], [2, 3, 4]])
    
    var reality = Trie([[3, 4, 5], [2, 3, 4]])
    
    reality.insert([1, 2, 3])
    
    XCTAssert(expectation == reality)
    
  }
  
  func testContents() {
    
    let expectation = [[1, 2, 3], [3, 4, 5], [2, 3, 4]].sort { $0.first < $1.first }
    
    let reality = Trie([[1, 2, 3], [3, 4, 5], [2, 3, 4]]).contents.sort { $0.first < $1.first }
    
    XCTAssert(expectation == reality)
    
  }
  
  func testCompletions() {
    
    let trie = Trie([[1, 2, 3], [1, 2, 3, 4], [1, 2, 5, 6], [3, 4, 5]])
    
    let expectation = [[1, 2, 3], [1, 2, 3, 4], [1, 2, 5, 6]].sort { $0.last < $1.last }
    
    let reality = trie.completions([1, 2]).sort { $0.last < $1.last }
    
    XCTAssert(expectation == reality)
    
  }
  
}