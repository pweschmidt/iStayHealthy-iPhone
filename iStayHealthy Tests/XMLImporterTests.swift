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
    var normalXMLData: NSData?
    
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
            normalXML = parsedString as? String
            self.normalXMLData = normalData
        }
    }
    
    override func tearDown()
    {
        super.tearDown()
    }

    func testXMLImporter()
    {
        XCTAssertNotNil(self.normalXMLData, "The XML data should not be nil")
        if nil == self.normalXMLData
        {
            return
        }
        
        var importer: PWESCoreXMLImporter = PWESCoreXMLImporter()
        importer.importWithData(normalXMLData!, completionBlock: { (success, dictionary, error) -> Void in
            if success
            {
                println("We got SUCCESS")
            }
            else
            {
                println("We got a FAILURE")
            }
            
            if nil != dictionary
            {
                let dict: NSDictionary = dictionary!
                var result: NSMutableArray? = dict.valueForKey("Results") as? NSMutableArray
                if nil != result
                {
                    let count: Int = result!.count
                    XCTAssertTrue(0 < count, "We expected more than 0 results")
                    println("We got a results array back and it has \(count) entries")
                }
            }
            
        })
       XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
