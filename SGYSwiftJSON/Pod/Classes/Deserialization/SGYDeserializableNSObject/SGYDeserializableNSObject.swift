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
    
    public enum Error: ErrorType { case InvalidSetValueObject }
    
    // Deserialization requires a parameterless initalizer
    public required override init() { super.init() }
    
    public func setValue(value: Any?, property: String) throws {
        // Since we're utilizing our category on NSObject we can only accept AnyObject
        guard let objectValue = value as? AnyObject else { throw Error.InvalidSetValueObject }
        var error: NSError?
        trySetValue(objectValue, forKey: property, error: &error)
        // Throw error if populated
        if let e = error { throw e }
    }
}
