import XCTest
import SwiftSequence

class ZipTests: XCTestCase {
  
  var allTests : [(String, () -> ())] {
    return [
      ("testWithNilPadding", testWithNilPadding),
      ("testZipWithCustomPadding", testZipWithCustomPadding)
    ]
  }
  
  func testWithNilPadding() {
    
    for (a,b) in zip((0...10).map(Array<Int>.init), (0...10).reverse().map(Array<Int>.init)) {
      
      let wa = WatcherSequence(a)
      let wb = WatcherSequence(b)
      
      let zipped = zipWithPadding(wa,wb)
      XCTAssertEqual(Array(zipped).count, max(a.count,b.count))
      let ta = zipped.map(fst).prefixWhile { e in e != nil }.flatMap { id in id }
      let tb = zipped.map(snd).prefixWhile { e in e != nil }.flatMap { id in id }
      XCTAssertEqual(a, Array(ta))
      XCTAssertEqual(b, Array(tb))
      
    }
    
  }
  
  func testZipWithCustomPadding() {
    
    for (ba,bb) in zip((0...10).map(Array<Int>.init), (0...10).reverse().map(Array<Int>.init)) {
      
      let an = Int.rand
      let bn = Int.rand
      
      let aPred = { i in i != an }
      let bPred = { i in i != bn }
      
      let a = ba.filter(aPred)
      let b = bb.filter(bPred)
      
      let wa = WatcherSequence(a)
      let wb = WatcherSequence(b)
      
      let zipped = zipWithPadding(wa,wb,pad0: an,pad1: bn)
      
      XCTAssertEqual(Array(zipped).count, max(a.count,b.count))
      
      XCTAssertEqual(zipped.map(fst).prefixWhile(aPred),a)
      XCTAssertEqual(zipped.map(snd).prefixWhile(bPred),b)
      
    }
    
  }
}