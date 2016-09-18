import UIKit
import XCTest
import SGYSwiftJSON

class ComplexObject: JSONCreatableObject {
    
    convenience init(number: NSNumber) {
        self.init()
        self.number = number
    }
    
    var number: NSNumber?
//    var shape: Shape?
    
    var complexDict: [String: ComplexObject]?
    
//    override func setValue(value: Any, property: String) throws {
//        if property == "color" { color = value as? Color }
//        else if property == "shape" { shape = value as? Shape }
//        else { try super.setValue(value, property: property) }
//    }
    
}

class Tests: XCTestCase {
    
    var serializer = SGYJSONSerializer()
    var deserializer = SGYJSONDeserializer()
    
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
        
        
        // Create test object
        let complexObj = ComplexObject(number: testInt)
        
        // -- Serialize
        let objData = try? serializer.serialize(complexObj)
        XCTAssertNotNil(objData, "Complex object should serialize.")
        
        // -- Foundation deserialize
        let jsonObj = try? JSONSerialization.jsonObject(with: objData!, options: []) as? [String: Any]
        XCTAssertNotNil(jsonObj, "Resulting json should deserialize.")
        
        // -- Property checks
        XCTAssert(jsonObj??["number"] as? NSNumber == testInt, "Deserialize NSNumbers should be equal.")
    }
    
    /**
    
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
    **/
}
