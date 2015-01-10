//
//  XMLImporterTests.swift
//  iStayHealthy
//
//  Created by Peter_Schmidt on 10/01/2015.
//
//

import UIKit
import XCTest

class XMLImporterTests: XCTestCase {

    var normalXML: String?
    
    override func setUp()
    {
        super.setUp()
        let bundle = NSBundle(forClass: XMLImporterTests.self)
        var normalPath = bundle.pathForResource("iStayHealthy.isth", ofType: nil)
        if nil != normalPath
        {
            var normalData = NSData.init(contentsOfFile: normalPath!)
            var parsedString = NSString(data: normalData!, encoding:NSUTF8StringEncoding)
            if nil != parsedString
            {
                println("XML \(parsedString)")
            }
            normalXML = parsedString
        }
    }
    
    override func tearDown()
    {
        super.tearDown()
    }

    func testXMLImporter()
    {
        var importer: PWESCoreXMLImporter = PWESCoreXMLImporter()
       XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
