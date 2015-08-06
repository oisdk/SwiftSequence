import XCTest
@testable import SwiftSequence

class PermutationsTests: XCTestCase {
  // MARK: Eager
  
  func testLexPermsClosure() {
    
    let forward = [1, 2, 3].lexPermutations(<)
    
    let fExpectation = [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
    
    XCTAssert(forward == fExpectation)
    
    let backward = [1, 2, 3].lexPermutations(>)
    
    let bExpectation = [[1, 2, 3]]
    
    XCTAssert(backward == bExpectation)
    
  }
  
  func testLexPerms() {
    
    let forward = [1, 2, 3].lexPermutations()
    
    let fExpectation = [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
    
    XCTAssert(forward == fExpectation)
    
    let backward = [3, 2, 1].lexPermutations()
    
    let bExpectation = [[3, 2, 1]]
    
    XCTAssert(backward == bExpectation)
    
  }
  
  func testPermsInds() {
    
    let perms = [1, 2, 3].permutations()
    
    let expectation = [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
    
    XCTAssert(perms == expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyLexPermsClosure() {
    
    let forward = [1, 2, 3].lazyLexPermutations(<)
    
    let fExpectation = [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
    
    XCTAssert(forward.elementsEqual(fExpectation, isEquivalent: ==))
    
    let backward = [1, 2, 3].lazyLexPermutations(>)
    
    let bExpectation = [[1, 2, 3]]
    
    XCTAssert(backward.elementsEqual(bExpectation, isEquivalent: ==))
    
    let _ = forward.array()
    let _ = backward.array()
    
  }
  
  func testLazyLexPerms() {
    
    let forward = [1, 2, 3].lazyLexPermutations()
    
    let fExpectation = [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
    
    XCTAssert(forward.elementsEqual(fExpectation, isEquivalent: ==))
    
    let backward = [3, 2, 1].lazyLexPermutations()
    
    let bExpectation = [[3, 2, 1]]
    
    XCTAssert(backward.elementsEqual(bExpectation, isEquivalent: ==))
    
    let _ = forward.array()
    let _ = backward.array()
    
  }
  
  func testLazyPermsInds() {
    
    let perms = [1, 2, 3].lazyPermutations()
    
    let expectation = [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
    
    XCTAssert(perms.elementsEqual(expectation, isEquivalent: ==))
    
    let _ = perms.array()
    
  }
}