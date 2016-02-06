// https://github.com/Quick/Quick

import Quick
import Nimble
import SGYSwiftJSON

class ComplexObject: JSONCreatableObject {
    
    convenience init(number: NSNumber) {
        self.init()
        self.number = number
    }
    
    var number: NSNumber?
    var string: String?
    
    var complexObj: ComplexObject?
    var complexArr: [ComplexObject]?
    var complexDict: [String: ComplexObject]?
    
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
                object.complexObj = object
                
                object.complexObj = ComplexObject(number: 2)
                object.complexArr = [ComplexObject(number: 3), ComplexObject(number: 4)]
                object.complexDict = ["5": ComplexObject(number: 5), "6": ComplexObject(number: 6)]
                
                let jsonData = try! serializer.serialize(object)
                
//                NSLog("JSON STRING:")
//                NSLog("\(NSString(data: jsonData, encoding: NSUTF8StringEncoding))")
//                NSLog("&&& END JSON")
                
                let jsonDict = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
                expect(jsonDict["number"]) == NSNumber(int: 10)
                expect(jsonDict["string"]) == "string val"
                
                expect(jsonDict["complexObj"]??["number"]) == NSNumber(int: 2)
                
                expect(jsonDict["complexArr"]??[0]["number"]) == NSNumber(int: 3)
                expect(jsonDict["complexArr"]??[1]["number"]) == NSNumber(int: 4)

                expect(jsonDict["complexDict"]??["5"]??["number"]) == NSNumber(int: 5)
                expect(jsonDict["complexDict"]??["6"]??["number"]) == NSNumber(int: 6)
            }
            
            it("will deserialize") {
                let objPath = NSBundle(forClass: self.dynamicType).pathForResource("ComplexObject", ofType: "json")!
                let jsonData = NSData(contentsOfURL: NSURL(fileURLWithPath: objPath))!
                
                context("into complex object") {
                    let object: ComplexObject = try! deserializer.deserialize(jsonData)
                    expect(object.number) == 10
                    expect(object.string) == "string val"
                    expect(object.complexObj?.number) == 2
                    expect(object.complexArr?[0].number) == 3
                    expect(object.complexArr?[1].number) == 4
                    expect(object.complexDict?["5"]?.number) == 5
                    expect(object.complexDict?["6"]?.number) == 6
                }
                
                context("into a dictionary") {
                    let dictionary: [String: AnyObject] = try! deserializer.deserialize(jsonData)
                    expect(dictionary["number"] as? NSNumber) == NSNumber(int: 10)
                    expect(dictionary["string"] as? String) == "string val"
                    expect(dictionary["complexObj"]?["number"]) == NSNumber(int: 2)
                    
                    expect(dictionary["complexArr"]?[0]["number"]) == NSNumber(int: 3)
                    expect(dictionary["complexArr"]?[1]["number"]) == NSNumber(int: 4)
                    
                    expect(dictionary["complexDict"]?["5"]??["number"]) == NSNumber(int: 5)
                    expect(dictionary["complexDict"]?["6"]??["number"]) == NSNumber(int: 6)
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
                    let array: [String] = try! deserializer.deserialize(jsonData)
                    expect(array[0]) == "1"
                    expect(array[1]) == "2"
                    expect(array[2]) == "3"
                }
                
                context("into date array") {
                    deserializer.dateConversionBlock = { (jsonValue) -> NSDate? in
                        let unixInterval = (jsonValue as? NSNumber)?.doubleValue ?? 0
                        return NSDate(timeIntervalSince1970: unixInterval)
                    }
                    
                    let array: [NSDate] = try! deserializer.deserialize(jsonData)
                    expect(array[0]) == NSDate(timeIntervalSince1970: 1)
                    expect(array[1]) == NSDate(timeIntervalSince1970: 2)
                    expect(array[2]) == NSDate(timeIntervalSince1970: 3)
                }
            }
        }
    }
}

//class DictionaryConversionSpec: QuickSpec {
//    override func spec() {
//        let serializer = SGYJSONSerializer()
//        let deserializer = SGYJSONDeserializer()
//        
//        describe("dictionary will convert properly"
//    }
//    
//    
//    
//}
