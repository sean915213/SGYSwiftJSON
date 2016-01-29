//
//  SGYJSONSerializableNSObject.swift
//  SGYSwiftJSON
//
//  Created by Sean Young on 9/17/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import UIKit

// Cannot blindly extend NSObject for its setValue function because that affects NSDictionary, NSArray, etc.  Instead it is much simpler inherit for this functionality.

/// A class provided for simple implementation of SGYKeyValueCreatable via inheritence.
public class SGYDeserializableNSObject: NSObject, SGYKeyValueCreatable {
    
    // Deserialization requires a parameterless initalizer
    public required override init() { super.init() }
    
    public func setValue(value: AnyObject?, property: String) throws {
        var error: NSError?
        trySetValue(value, forKey: property, error: &error)
        // Throw error if populated
        if let e = error { throw e }
    }
}
