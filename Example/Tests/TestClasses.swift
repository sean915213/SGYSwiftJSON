//
//  TestClasses.swift
//  SGYSwiftJSON
//
//  Created by Sean G Young on 10/22/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import SGYSwiftJSON

enum Color: Int, JSONLeafEnum {
    case red, blue, green, yellow
}

enum Shape: String, JSONLeafEnum {
    case square = "square", circle = "circle", oval = "oval"
}

class BaseComplexObject: JSONCreatableObject {
    
    var complexObj: ComplexObject?
    var complexArr: [ComplexObject]?
    
    var string: String?
    var color: Color?
    var date: Date?
    
    override func setValue(_ value: Any, property: String) throws {
        if property == "color" { color = value as? Color }
        else { try super.setValue(value, property: property) }
    }
}

class ComplexObject: BaseComplexObject {
    
    convenience init(number: NSNumber) {
        self.init()
        self.number = number
    }
    
    var number: NSNumber?
    var shape: Shape?
    
    var complexDict: [String: ComplexObject]?
    
    override func setValue(_ value: Any, property: String) throws {
        if property == "shape" { shape = value as? Shape }
        else { try super.setValue(value, property: property) }
    }
}
