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
    
    - throws: Throws an SGYJSONErrors case.
    */
    func setValue(value: AnyObject?, property: String) throws
}

// Utility protocols

/**
*  Defined to allow attempting the assignment of a deserialized array.
*/
public protocol SGYCollectionCreatable: SGYJSONCreatable, SGYCollectionReflection {

    /**
    Attempts appending the contents of an untyped AnyObject array.
    
    - parameter array: An array of AnyObject.
    */
    mutating func appendContentsOf(array: [AnyObject])
}

/**
*  Defined to allow attempting the assignment of a deserialized dictionary.
*/
public protocol SGYDictionaryCreatable: SGYJSONCreatable, SGYDictionaryReflection {

    /**
    Attempts merging the contents of a [String: AnyObject] dictionary.
    
    - parameter dictionary: A [String: AnyObject] dictionary to attempt merging.
    */
    mutating func mergeContentsOf(dictionary: [String: AnyObject])
}











