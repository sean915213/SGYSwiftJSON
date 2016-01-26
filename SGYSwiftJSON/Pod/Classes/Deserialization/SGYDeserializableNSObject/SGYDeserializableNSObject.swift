//
//  SGYJSONSerializableNSObject.swift
//  SGYSwiftConverterTest
//
//  Created by Sean Young on 9/17/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import UIKit

class SGYDeserializableNSObject: NSObject, SGYKeyValueCreatable {
    
    // Deserialization requires a parameterless initalizer
    required override init() { super.init() }
    
    func setValue(value: AnyObject?, property: String) throws {
        var error: NSError?
        trySetValue(value, forKey: property, error: &error)
        // Throw error if populated
        if let e = error { throw e }
    }
}
