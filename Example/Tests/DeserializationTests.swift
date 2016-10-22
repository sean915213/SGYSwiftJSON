import UIKit
import XCTest
import SGYSwiftJSON

class DeserializationTests: XCTestCase {
    
    let deserializer: SGYJSONDeserializer = {
        let d = SGYJSONDeserializer()
        d.dateConversionBlock = { (value) in
            guard let number = value as? NSNumber else { return nil }
            return Date(timeIntervalSince1970: number.doubleValue)
        }
        return d
    }()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testComplexObjectDeserialization() {
        let jsonData = readJSONData(fromFile: "ComplexObject")
        
        // Serialize
        let obj: ComplexObject! = try? deserializer.deserialize(jsonData)
        XCTAssertNotNil(obj)
        
        // Properties
        XCTAssertEqual(obj.color, Color.yellow)
        XCTAssertEqual(obj.number, NSNumber(integerLiteral: 45))
        XCTAssertEqual(obj.shape, Shape.circle)
        XCTAssertEqual(obj.string, "test string value")
        XCTAssertEqual(obj.date, Date(timeIntervalSince1970: 10000))
        XCTAssertEqual(obj.double, 33.3)
        // Dictionary
        for i in 1...5 {
            XCTAssertEqual(obj.complexDict?["\(i)"]?.number, NSNumber(integerLiteral: i))
        }
        // Array
        for i in 0...4 {
            XCTAssertEqual(obj.intArray?[i], i)
        }
    }
    
    func testArrayDeserialization() {
        let doubleArray = [1.0, 50.0, 100, 45.0]
        let jsonData = try! JSONSerialization.data(withJSONObject: doubleArray, options: [])
        
        let array: [Double]! = try? deserializer.deserialize(jsonData)
        XCTAssertNotNil(array)
        XCTAssertEqual(array, doubleArray)
    }
    
    private func readJSONData(fromFile file: String) -> Data {
        let jsonUrl = Bundle(for: type(of: self)).url(forResource: file, withExtension: "json")!
        return try! Data(contentsOf: jsonUrl, options: [])
    }
}


