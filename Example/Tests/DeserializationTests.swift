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
        
        // NOTE: Not sure why but cannot assign to implicitly unwrapped veriable inside do loop unless doing type switching below
        var obj: ComplexObject!
        do {
            let result: (ComplexObject, [SGYJSONDeserializer.Warning]?) = try deserializer.deserialize(jsonData)
            obj = result.0
            // Assert that a single warning exists for KVO error on optional int
            XCTAssert(result.1?.count == 1)
            
        } catch let err {
            XCTFail("Deserialize threw error: \(err).")
            return
        }
        
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
        let testArray = [1, 50, 100, 45]
        let jsonData = try! JSONSerialization.data(withJSONObject: testArray, options: [])
        
        // Deserialize into int
        arrayCheck(jsonData, againstArray: testArray)
        // Deserialize into double
        arrayCheck(jsonData, againstArray: testArray.map { Double($0) })
        // Deserialize into dates
        arrayCheck(jsonData, againstArray: testArray.map { Date(timeIntervalSince1970: TimeInterval($0)) })
    }
    
    private func arrayCheck<T>(_ jsonData: Data, againstArray: [T]) where T: Equatable {
        // Deserialize into int
        let testArray: [T]? = try? deserializer.deserialize(jsonData)
        XCTAssertNotNil(testArray)
        XCTAssertEqual(testArray!, againstArray)
        
        /**
        let intResult: ([T], [SGYJSONDeserializer.Warning]?)? = try? deserializer.deserialize(jsonData)
        XCTAssertNotNil(intResult?.0)
        XCTAssertEqual(intResult!.0, againstArray)
 **/
    }
    
    private func readJSONData(fromFile file: String) -> Data {
        let jsonUrl = Bundle(for: type(of: self)).url(forResource: file, withExtension: "json")!
        return try! Data(contentsOf: jsonUrl, options: [])
    }
}


