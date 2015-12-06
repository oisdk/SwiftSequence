import XCTest
import SwiftSequence
import Darwin

class CombinationsTests: XCTestCase {
  
  
  var allTests : [(String, () -> ())] {
    return [
      ("testCombosWithoutRep", testCombosWithoutRep),
      ("testCombosWithRep", testCombosWithRep),
      ("testLazyCombosWithoutRep", testLazyCombosWithoutRep),
      ("testLazyCombosWithRep", testLazyCombosWithRep),
      ("testNoDuplicates", testNoDuplicates)
    ]
  }
  
  // MARK: Eager
  
  func testCombosWithoutRep() {
    
    for randAr in (1...10).map(Array<Character>.init) {
      
      let n = randAr.count
      let r = Int(arc4random()) % n + 1
      
      let expectedCount = choose(n, r)
      let realSeq = randAr.combos(r)
      
      let failString: () -> String = { "\n" +
        "From array: " + randAr.description + "\n" +
        "To combinations: " + realSeq.description + "\n" +
        "Of count: " + r.description
      }
      
      XCTAssertEqual(realSeq.count, expectedCount, failString())
      
    }
    
  }
  
  func testCombosWithRep() {
    
    for randAr in (1...10).map(Array<Character>.init) {
      
      let n = randAr.count
      let r = Int(arc4random()) % n + 1
      
      let expectedCount = chooseRep(n, r)
      let realSeq = randAr.combosWithRep(r)
      
      let failString: () -> String = { "\n" +
        "From array: " + randAr.description + "\n" +
        "To combinations: " + realSeq.description + "\n" +
        "Of count: " + r.description
      }
      
      XCTAssertEqual(realSeq.count, expectedCount, failString())
      
    }
    
  }
  
  // MARK: Lazy
  
  func testLazyCombosWithoutRep() {
    
    for randAr in (0..<10).map(Array<Character>.init) {
      
      let eager = randAr.combos(min(randAr.count, 3))
      
      let lazy = randAr.lazyCombos(min(randAr.count, 3))
      
      XCTAssertEqualNested(eager, lazy)
      
    }
    
  }
  
  func testLazyCombosWithRep() {
    
    for randAr in(0..<10).map(Array<Character>.init) {
      
      let eager = randAr.combosWithRep(min(randAr.count, 3))
      
      let lazy = randAr.lazyCombosWithRep(min(randAr.count, 3))
      
      XCTAssertEqualNested(eager, lazy)
      
    }
    
  }
  
  func testNoDuplicates() {
    
    var letters: Set<Character> = []
    while letters.count < 10 {
      letters.insert(
        Character(
          UnicodeScalar(arc4random_uniform(156) + 100)
        )
      )
    }
    
    let sComboes    = letters.combos(5).map(String.init)
    let lComboes    = Array(letters.lazyCombos(5).map(String.init))
    let sRepComboed = letters.combosWithRep(5).map(String.init)
    let lRepComboed = Array(letters.lazyCombosWithRep(5).map(String.init))
    
    XCTAssertEqual(sComboes.count, Set(sComboes).count)
    XCTAssertEqual(lComboes.count, Set(lComboes).count)
    XCTAssertEqual(sRepComboed.count, Set(sRepComboed).count)
    XCTAssertEqual(lRepComboed.count, Set(lRepComboed).count)
    
  }
  
  
}