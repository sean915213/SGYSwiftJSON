//
//  SGYDeserializationExtensions.swift
//  SGYSwiftJSON
//
//  Created by Sean Young on 8/23/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import Foundation

extension NSObject: SGYKeyValueCreatable {
    
    public func setValue(value: AnyObject?, property: String) throws {
        var error: NSError?
        trySetValue(value, forKey: property, error: &error)
        // Throw error if populated
        if let e = error { throw e }
    }
}

extension RangeReplaceableCollectionType where Self: SGYCollectionCreatable {
    public mutating func appendContentsOf(array: [AnyObject]) {
        array.forEach { if let e = $0 as? Generator.Element { append(e) } }
    }
}

extension Dictionary: SGYDictionaryCreatable {
    public mutating func mergeContentsOf(dictionary: [String: AnyObject]) {
        dictionary.forEach {
            if let k = $0 as? Key, v = $1 as? Value { self[k] = v }
        }
    }
}

// Simple declarations that these types adhere, allowing extension on protocol to do the work

extension Array: SGYCollectionCreatable { }

extension Set: SGYCollectionCreatable {
    public mutating func appendContentsOf(array: [AnyObject]) {
        array.forEach { if let e = $0 as? Element { insert(e) } }
    }
}



