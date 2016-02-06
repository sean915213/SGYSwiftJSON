// https://github.com/Quick/Quick

import Quick
import Nimble
import SGYSwiftJSON

class ComplexObject: JSONCreatableObject {
    
    var number: NSNumber?
    var string: String?
    
}

class ComplexObjectConversionSpec: QuickSpec {
    override func spec() {
        let serializer = SGYJSONSerializer()
        let deserializer = SGYJSONDeserializer()
        
        describe("complex object") {
            it("will serialize") {
                let object = ComplexObject()
                object.number = 10
                object.string = "string val"
                
                let jsonData = try! serializer.serialize(object)
                let jsonDict = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
                expect(jsonDict["number"]) == NSNumber(int: 10)
                expect(jsonDict["string"]) == "string val"
            }
            
            it("will deserialize") {
                let jsonString = "{\"number\":10, \"string\":\"string val\"}"
                let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
                
                context("into complex object") {
                    let object: ComplexObject = try! deserializer.deserialize(jsonData)
                    expect(object.number) == 10
                    expect(object.string) == "string val"
                }
                
                context("into a dictionary") {
                    let dictionary: [String: AnyObject] = try! deserializer.deserialize(jsonData)
                    expect(dictionary["number"] as? NSNumber) == NSNumber(int: 10)
                    expect(dictionary["string"] as? String) == "string val"
                }
            }
        }
    }
    
}

class ArrayConverionSpec: QuickSpec {
    override func spec() {
        let serializer = SGYJSONSerializer()
        let deserializer = SGYJSONDeserializer()
        
        describe("array will convert properly") { () -> Void in
            let intArray = [1, 2, 3]
            var intArrayJson: NSData!
            
            it("will serialize", closure: { () -> () in
                intArrayJson = try! serializer.serialize(intArray)
                let intArrayObj: [NSNumber]! = try! NSJSONSerialization.JSONObjectWithData(intArrayJson, options: []) as? [NSNumber]
                expect(intArrayObj).toNot(beNil())
                expect(intArrayObj[0]) == NSNumber(int: 1)
                expect(intArrayObj[1]) == NSNumber(int: 2)
                expect(intArrayObj[2]) == NSNumber(int: 3)
            })
            
            it("will deserialize") {
                let jsonString = "[1, 2, 3]"
                let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
                
                context("into int array") {
                    let array: [Int] = try! deserializer.deserialize(jsonData)
                    expect(array[0]) == 1
                    expect(array[1]) == 2
                    expect(array[2]) == 3
                }
                
                context("into string array") {
                    let array: [String] = try! deserializer.deserialize(intArrayJson)
                    expect(array[0]) == "1"
                    expect(array[1]) == "2"
                    expect(array[2]) == "3"
                }
            }
        }
    }
    
}
