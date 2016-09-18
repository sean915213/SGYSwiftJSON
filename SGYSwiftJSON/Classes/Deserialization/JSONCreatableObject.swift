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
     Errors thrown by this class.
     */
    public enum KeyValueError: Error {
        /**
         Indicates that the `value` passed to `setValue:property` could not be converted to `AnyObject`.  This is a requirement for this class.
         
         - returns: An `InvalidSetValueObject` case.
         */
        case invalidSetValueObject
    }
    
    /**
     A required parameterless initializer in order to conform to `JSONKeyValueCreatable`.
     
     - returns: An initialized instance.
     */
    public required override init() {
        super.init()
    }
    
    /**
     Implement's `JSONKeyValueCreatable`'s method for setting deserialized values. The `value` passed must be castable to `AnyObject` or an `Error` case is thrown.
     
     - parameter value:    The deserialized value.
     - parameter property: The name of the property.
     
     - throws: An `JSONCreatableObject.Error` case or exceptions thrown by `NSObject`.
     */
    open func setValue(_ value: Any, property: String) throws {
        // Since we're utilizing our category on NSObject we can only accept AnyObject
        guard let objectValue = value as? AnyObject else { throw KeyValueError.invalidSetValueObject }
        var error: NSError?
        setValue(objectValue, forKey: property, error: &error)
        // Throw error if populated
        if let e = error { throw e }
    }
}
