//
//  URLImporterTests.swift
//  iStayHealthy
//
//  Created by Peter_Schmidt on 18/01/2015.
//
//

import UIKit
import XCTest

class URLImporterTests: XCTestCase {

    let testStringShort = "iStayHealthy://results?CD4=555&ResultsDate=16Jan2015"
    let testURL = "https://www.dropbox.com/s/d3bvjfp5e9jcqtw/TestiStayHealthyLink.html?dl=0"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }

}
