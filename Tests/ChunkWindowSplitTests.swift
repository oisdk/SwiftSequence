import XCTest
import SwiftSequence

class ChunkWindowSplitTests: XCTestCase {
  
  var allTests : [(String, () -> ())] {
    return [
      ("testChunk", testChunk),
      ("testWindow", testWindow),
      ("testLazyChunk", testLazyChunk),
      ("testLazyWindow", testLazyWindow),
      
    ]
  }
  
  // MARK: Eager
  
  func testChunk() {
    
    for randAr in (1...20).map(Array<Int>.init) {
      let n = Int(arc4random()) % randAr.count + 1
      let chunkd = randAr.chunk(n)
      for a in chunkd {
        XCTAssert( a.count <= n )
      }
      XCTAssertEqualSeq(chunkd.flatten(), randAr)
    }
    
  }
  
  func testWindow() {
    
    for randAr in (1...20).map(Array<Int>.init) {
      let n = Int(arc4random()) % randAr.count + 1
      let windowed = randAr.window(n)
      for i in windowed.map ({ a in a.count }) {
        XCTAssertEqual(n, i)
      }
      XCTAssertEqual(randAr, windowed.first!.dropLast() + windowed.flatMap { a in a.last })
    }
    
  }
  
  // MARK: Lazy
  
  func testLazyChunk() {
    
    for randAr in (1...20).map(Array<Int>.init) {
      let n = Int(arc4random()) % randAr.count + 1
      XCTAssertEqualNested(randAr.lazy.chunk(n), randAr.chunk(n))
    }
  }
  
  func testLazyWindow() {
    
    for randAr in (1...20).map(Array<Int>.init) {
      let n = Int(arc4random()) % randAr.count + 1
      XCTAssertEqualNested(randAr.lazy.window(n), randAr.window(n))
    }
  }
}