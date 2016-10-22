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
    
    func testArraySerialization() {
        let testArray = [1.0, 50.0, 100, 45.0]
        // Serialize
        let arrayData = try? serializer.serialize(testArray)
        XCTAssertNotNil(arrayData)
        
        // Foundation deserialize
        let jsonArray = try? JSONSerialization.jsonObject(with: arrayData!, options: []) as? [Double]
        XCTAssertNotNil(jsonArray)
        
        XCTAssertEqual(jsonArray!!, testArray)
    }
    
    func testComplexObjectSerialization() {
        // Test properties
        let testInt = NSNumber(integerLiteral: 45)
        let testString = "test string value"
        let testColor = Color.yellow
        let testShape = Shape.circle
        let testDate = Date(timeIntervalSince1970: 10000)
        let testDouble = 33.3
        let testArray = [0, 1, 2, 3, 4]
        
        // Create test object
        let complexObj = ComplexObject(number: testInt)
        complexObj.string = testString
        complexObj.color = testColor
        complexObj.shape = testShape
        complexObj.date = testDate
        complexObj.double = testDouble
        complexObj.intArray = testArray
        // - Nested dictionary
        complexObj.complexDict = [:]
        for i in 1...5 {
            complexObj.complexDict!["\(i)"] = ComplexObject(number: NSNumber(integerLiteral: i))
        }
        
        // Serialize
        let objData = try? serializer.serialize(complexObj)
        XCTAssertNotNil(objData)
        
        /**
        let jsonString = String(data: objData!, encoding: String.Encoding.utf8)!
        NSLog("&& JSON")
        NSLog("\(jsonString)")
 **/
        
        
        // Foundation deserialize
        let jsonObj = try? JSONSerialization.jsonObject(with: objData!, options: []) as? [String: Any]
        XCTAssertNotNil(jsonObj)
        
        // Property checks
        XCTAssertEqual(jsonObj??["string"] as? String, testString)
        XCTAssertEqual(jsonObj??["color"] as? Int, testColor.rawValue)
        XCTAssertEqual(jsonObj??["number"] as? NSNumber, testInt)
        XCTAssertEqual(jsonObj??["shape"] as? String, testShape.rawValue)
        XCTAssertEqual(jsonObj??["date"] as? TimeInterval, testDate.timeIntervalSince1970)
        XCTAssertEqual(jsonObj??["double"] as? Double, 33.3)
        // Nested dictionary
        let dict = jsonObj??["complexDict"] as? [String: [String: Any]]
        XCTAssertNotNil(dict)
        for i in 1...5 {
            XCTAssertEqual(dict?["\(i)"]?["number"] as? NSNumber, NSNumber(integerLiteral: i))
        }
        // Array
        let array = jsonObj??["intArray"] as? [Int]
        XCTAssertNotNil(array)
        XCTAssertEqual(array!, testArray)
        
        /**
        XCTAssertNotNil(array)
        for i in 0...4 {
            XCTAssertEqual(array![i], i)
        }
 **/
    }
    
}
