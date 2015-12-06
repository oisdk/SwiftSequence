import XCTest
import SwiftSequence

class PermutationsTests: XCTestCase {
  
  var allTests : [(String, () -> ())] {
    return [
      ("testLexPermsClosure", testLexPermsClosure),
      ("testLexPerms", testLexPerms),
      ("testPermsInds", testPermsInds),
      ("testLazyLexPermsClosure", testLazyLexPermsClosure),
      ("testLazyLexPerms", testLazyLexPerms),
      ("testLazyPermsInds", testLazyPermsInds),
      ("testCounts", testCounts)
    ]
  }
  
  // MARK: Eager
  
  func testLexPermsClosure() {
    
    let forward = [1, 2, 3].lexPermutations(<)
    
    let fExpectation = [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
    
    XCTAssert(forward == fExpectation)
    
    let backward = [1, 2, 3].lexPermutations(>)
    
    let bExpectation = [[1, 2, 3]]
    
    XCTAssertEqual(backward)(bExpectation)
    
  }
  
  func testLexPerms() {
    
    let forward = [1, 2, 3].lexPermutations()
    
    let fExpectation = [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
    
    XCTAssert(forward == fExpectation)
    
    let backward = [3, 2, 1].lexPermutations()
    
    let bExpectation = [[3, 2, 1]]
    
    XCTAssertEqual(backward)(bExpectation)
    
  }
  
  func testPermsInds() {
    
    let perms = [1, 2, 3].permutations()
    
    let expectation = [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
    
    XCTAssertEqual(perms)(expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyLexPermsClosure() {
    
    let forward = [1, 2, 3].lazyLexPermutations(<)
    
    let fExpectation = [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
    
    XCTAssertEqual(forward)(fExpectation)
    
    let backward = [1, 2, 3].lazyLexPermutations(>)
    
    let bExpectation = [[1, 2, 3]]
    
    XCTAssertEqual(backward)(bExpectation)

    
  }
  
  func testLazyLexPerms() {
    
    let forward = [1, 2, 3].lazyLexPermutations()
    
    let fExpectation = [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
    
    XCTAssertEqual(forward)(fExpectation)
    
    let backward = [3, 2, 1].lazyLexPermutations()
    
    let bExpectation = [[3, 2, 1]]
    
    XCTAssertEqual(backward)(bExpectation)

    
  }
  
  func testLazyPermsInds() {
    
    let perms = [1, 2, 3].lazyPermutations()
    
    let expectation = [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
    
    XCTAssertEqual(perms)(expectation)
    
  }
  
  func nk(n: Int, _ k: Int) -> Int {
    let num = n.fac
    let den = (n - k).fac
    return num / den
  }
  
  func testCounts() {
    
    for randAr in (1...5).map(Array<Character>.init) {
      XCTAssertEqual(randAr.permutations().count)(randAr.count.fac)
      let i = Int.randLim(randAr.count) + 1
      XCTAssertEqual(randAr.permutations(i).count)(nk(randAr.count, i))
    }
  }
}