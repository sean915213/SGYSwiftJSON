//
//  SerializationTests.swift
//  SGYSwiftJSON
//
//  Created by Sean G Young on 10/22/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import SGYSwiftJSON

class SerializationTests: XCTestCase {
    
    let serializer: SGYJSONSerializer = {
        let s = SGYJSONSerializer()
        s.dateConversionBlock = { (date) in
            let unixTS = date.timeIntervalSince1970
            return JSONLeafValue(NSNumber(value: unixTS))
        }
        return s
    }()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testComplexObjectSerialization() {
        // Test properties
        let testInt = NSNumber(integerLiteral: 45)
        let testString = "test string value"
        let testColor = Color.yellow
        let testShape = Shape.circle
        let testDate = Date(timeIntervalSince1970: 10000)
        
        // Create test object
        let complexObj = ComplexObject(number: testInt)
        complexObj.string = testString
        complexObj.color = testColor
        complexObj.shape = testShape
        complexObj.date = testDate
        // - Nested dictionary
        complexObj.complexDict = [:]
        for i in 1...5 {
            complexObj.complexDict!["\(i)"] = ComplexObject(number: NSNumber(integerLiteral: i))
        }
        
        // Serialize
        let objData = try? serializer.serialize(complexObj)
        XCTAssertNotNil(objData, "Complex object should serialize.")
        
        /**
        let jsonString = String(data: objData!, encoding: String.Encoding.utf8)!
        NSLog("&& JSON")
        NSLog("\(jsonString)")
 **/
        
        
        // Foundation deserialize
        let jsonObj = try? JSONSerialization.jsonObject(with: objData!, options: []) as? [String: Any]
        XCTAssertNotNil(jsonObj, "Resulting json should deserialize.")
        
        // Property checks
        XCTAssertEqual(jsonObj??["string"] as? String, testString)
        XCTAssertEqual(jsonObj??["color"] as? Int, testColor.rawValue)
        XCTAssertEqual(jsonObj??["number"] as? NSNumber, testInt)
        XCTAssertEqual(jsonObj??["shape"] as? String, testShape.rawValue)
        XCTAssertEqual(jsonObj??["date"] as? TimeInterval, testDate.timeIntervalSince1970)
        // Nested dictionary
        let dict = jsonObj??["complexDict"] as? [String: [String: Any]]
        XCTAssertNotNil(dict, "Should deserialize complex object dictionary.")
        for i in 1...5 {
            XCTAssertEqual(dict?["\(i)"]?["number"] as? NSNumber, NSNumber(integerLiteral: i))
        }
    }
    
}
