//
//  JSONCreatableObject.swift
//  SGYSwiftJSON
//
//  Created by Sean Young on 9/17/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import UIKit
import SGYKVCSafeNSObject

// Cannot blindly extend NSObject for its setValue function because that affects NSDictionary, NSArray, etc.  Instead it is much simpler inherit for this functionality.

/// A class provided for simple implementation of `JSONKeyValueCreatable` via inheritence.
open class JSONCreatableObject: NSObject, JSONKeyValueCreatable {
    
    /**
     A required parameterless initializer in order to conform to `JSONKeyValueCreatable`.
     
     - returns: An initialized instance.
     */
    public required override init() {
        super.init()
    }
    
    /**
     Implement's `JSONKeyValueCreatable`'s method for setting deserialized values.
     
     - parameter value:    The deserialized value.
     - parameter property: The name of the property.
     
     - throws: Exceptions produced by `NSObject`.
     */
    open func setValue(_ value: Any, property: String) throws {
        // Attempt setting value via KVC
        var error: NSError?
        setValue(value, forKey: property, error: &error)
        // Throw error if populated
        if let e = error { throw e }
    }
}
