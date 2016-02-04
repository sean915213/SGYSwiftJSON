//
//  SGYSwiftProtocols.swift
//  SGYSwiftJSON
//
//  Created by Sean Young on 8/29/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import Foundation

/**
*  The most basic protocol for any type that can be created from serialized JSON.
*/
public protocol SGYJSONCreatable {
    /**
    A required parameterless initializer.
    
    - returns: An initialized object.
    */
    init()
}

/**
*  The protocol a class must adhere to in-order to be creatable from a JSON dictionary.
*/
public protocol SGYKeyValueCreatable: class, SGYJSONCreatable {
    /**
    The basic function facilitating an object's creation from a dictionary.
    
    - parameter value:    The object to set.
    - parameter property: The name of the property to assign the provided value.
    
    - throws: Throws an SGYDeserializableNSObject.Error case.
    */
    func setValue(value: Any, property: String) throws
}

// Utility protocols

/**
*  Defined to allow attempting the assignment of a deserialized array.
*/
public protocol SGYCollectionCreatable: SGYCollectionReflection {
    /**
     Initializes a type from a deserialized collection.
     
     - parameter array: An array of deserialized and converted values.
     
     - returns: A type initialized from the collection.
     */
    init(array: [AnyObject])
}

/**
*  Defined to allow attempting the assignment of a deserialized dictionary.
*/
public protocol SGYDictionaryCreatable: SGYDictionaryReflection {
    /**
     Initializes an object from a deserialized collection.
     
     - parameter array: A dictionary of deserialized and converted values.
     
     - returns: A type initialized from the dictionary.
     */
    init(dictionary: [String: AnyObject])
}

/**
 *  Defined to allow creation of types from JSONLeafValues (`NSString`, `NSNumber`, or `NSNull`).
 */
public protocol JSONLeafCreatable {
    init?(jsonValue: JSONLeafValue)
}







