//
//  DeserializationProtocols.swift
//  SGYSwiftJSON
//
//  Created by Sean Young on 8/29/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import Foundation

/**
*  The protocol a class must adhere to in-order to be creatable from a JSON dictionary.
*/
public protocol JSONKeyValueCreatable: class {
    /**
     A required parameterless initializer.
     
     - returns: An initialized object.
     */
    init()
    
    /**
    The basic function facilitating an object's creation from a dictionary.
    
    - parameter value:    The object to set.
    - parameter property: The name of the property to assign the provided value.
    
    - throws: Throws an JSONCreatableObject.Error case.
    */
    func setValue(_ value: Any, property: String) throws
}

// Utility protocols

/**
*  Defined to allow attempting the assignment of a deserialized array.
*/
public protocol JSONCollectionCreatable: SGYCollectionReflection {
    /**
     Initializes the type from a deserialized collection.
     
     - parameter array: An array of deserialized and converted values.
     
     - returns: A type initialized from the collection.
     */
    init(array: [Any])
}

/**
*  Defined to allow attempting the assignment of a deserialized dictionary.
*/
public protocol JSONDictionaryCreatable: SGYDictionaryReflection {
    /**
     Initializes the type from a deserialized dictionary.
     
     - parameter array: A dictionary of deserialized and converted values.
     
     - returns: A type initialized from the dictionary.
     */
    init(dictionary: [String: Any])
}

/**
 *  Defined to allow creation of types from JSONLeafValues (`NSString`, `NSNumber`, or `NSNull`).
 */
public protocol JSONLeafCreatable {
    /**
     Initializes the type from a deserialized JSON leaf value.
     
     - parameter jsonValue: An enumeration describing the JSON leaf value.
     
     - returns: The initialized type or nil.
     */
    init?(jsonValue: JSONLeafValue)
}







