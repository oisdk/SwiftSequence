import XCTest
@testable import SwiftSequence

class FindingTests: XCTestCase {

//  func testFindFirst() {
//    
//  }

  
  func testFindFirst() {
    
    let ar = Array<Int>(randLength: 100)
    
    let pred = randPred()
    
    let expectation = ar.indexOf(pred).map { i in ar[i] }
    
    let reality = ar.first(pred)
    
    XCTAssert(expectation == reality)
    
  }
  
  func testFindLast() {
    
    let ar = Array<Int>(randLength: 100)
    
    let pred = randPred()
    
    let rev = ar.reverse()
    
    let expectation = rev.indexOf(pred).map { i in rev[i] }
    
    let reality = ar.last(pred)
    
    XCTAssert(expectation == reality)
    
  }
  
  func testCount() {
    let ar = Array<Int>(randLength: 100)
    
    let pred = randPred()
    
    let expectation = ar.filter(pred).count
    
    let reality = ar.count(pred)
    
    XCTAssertEqual(expectation, reality)
    
  }
  
  func testLastIndexOf() {
    
    let ar = Array<Int>(randLength: 100)
    
    let pred = randPred()
    
    let expectation = ar.indices.last { i in pred(ar[i]) }
    
    let reality = ar.lastIndexOf(pred)
    
    XCTAssert(expectation == reality)
    
  }
  
  func testIndices() {
    
    let ar = Array<Int>(randLength: 100)
    
    let pred = randPred()
    
    let expectation = ar.indices.filter { i in pred(ar[i]) }
    
    let reality = ar.indicesOf(pred)
    
    XCTAssert(expectation == reality)
    
  }
  
  func testPartition() {
    let ar = Array<Int>(randLength: 100)
    
    let pred = randPred()
    
    let (pass,fail) = ar.partition(pred)
    
    XCTAssertEqual(ar.filter(pred))(pass)
    XCTAssertEqual(ar.filter { e in !pred(e) })(fail)
  }
}