//
//  SGYJSONSerializer.swift
//  SGYSwiftJSON
//
//  Created by Sean Young on 9/25/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import Foundation

public enum SGYSerializationError: ErrorType {
    case InvalidDictionaryKeyType(Any.Type),
    InvalidObject(Any)
}

public class SGYJSONSerializer {
    
    // MARK: - Initialization
    
    // MARK: - Properties
    
    public var strictMode = true
    public var convertNullToNil: Bool = true
    public var writingOptions = NSJSONWritingOptions()
    
    public var dateConversionBlock: ((date: NSDate) -> AnyObject?)?
    
    // MARK: - Methods
    // MARK: Public
    
    public func serialize(collection: SGYCollectionReflection) throws -> NSData {
        let array = try convertToValidCollection(collection)
        return try NSJSONSerialization.dataWithJSONObject(array, options: writingOptions)
    }
    
    public func serialize(dictionary: SGYDictionaryReflection) throws -> NSData {
        let dictionary = try convertToValidDictionary(dictionary)
        return try NSJSONSerialization.dataWithJSONObject(dictionary, options: writingOptions)
    }
    
    public func serialize(object: AnyObject) throws -> NSData {
        // Attempt converting object to dictionary
        let dictionary = try convertToValidDictionary(object)
        return try NSJSONSerialization.dataWithJSONObject(dictionary, options: writingOptions)
    }
    
    // MARK: Private
    
    private func convertToValidDictionary(object: AnyObject) throws -> [String: AnyObject] {
        // Converted dictionary
        var jsonDictionary = [String: AnyObject]()
        
        var mirror: Mirror? = Mirror(reflecting: object)
        while mirror != nil {
            // Pull values from mirror children
            for child in mirror!.children {
                // Make sure property has a label (don't know when it doesn't, but it's defined optional)
                guard let property = child.label else { continue }
                // Attempt parsing value into valid type
                guard let validObject = try convertToValidObject(child.value) else { continue }
                // Assign to dictionary
                jsonDictionary[property] = validObject
            }
            // Assign super's mirror if any and loop back through
            mirror = mirror!.superclassMirror()
        }
        
        return jsonDictionary
    }
    
    private func convertToValidCollection(collection: SGYCollectionReflection) throws -> [AnyObject] {
        var validCollection = [AnyObject]()
        // Get child values
        for (_, value) in Mirror(reflecting: collection).children {
            if let validObj = try convertToValidObject(value) { validCollection.append(validObj) }
        }
        // Return collection even if empty, caller determines what to do
        return validCollection
    }
    
    private func convertToValidDictionary(dictionary: SGYDictionaryReflection) throws -> [String: AnyObject] {
        var validDict = [String: AnyObject]()
        // Get child key-value tuples
        for (_, kvp) in Mirror(reflecting: dictionary).children {
            let tuplePair = Mirror(reflecting: kvp).children.map { $0.value }
            // Make sure key can be converted to a string
            guard let key = (tuplePair[0] as? SGYJSONStringConvertible)?.jsonString else {
                if strictMode { throw SGYSerializationError.InvalidDictionaryKeyType(tuplePair[0].dynamicType) }
                return validDict
            }
            
            // Assign if we receive valid result
            if let value = try convertToValidObject(tuplePair[1]) { validDict[key] = value }
        }
        
        return validDict
    }
    
    
    private func convertToValidObject(any: Any) throws -> AnyObject? {
        // Any could be optional but is not recognized as being able to be cast as such.  So unwrap using the protocol.
        guard let object = unwrap(any) else { return nil }
        
        // -- Check leaf objects first
        
        // Null
        if let nullObject = object as? NSNull {
            return convertNullToNil ? nil : nullObject
        }
        
        // Number
        // IMPORTANT: Check number before string since numbers always have a string representation, whereas strings do not always represent a valid number.  Checking number first prevents objects that should be serialized as numbers becoming strings.
        if let number = object as? SGYJSONNumberConvertible { return number.jsonNumber }
        // String
        if let string = object as? SGYJSONStringConvertible { return string.jsonString }
        
        // Date
        if let date = object as? NSDate {
            guard let dateVal = dateConversionBlock?(date: date) else { return nil }
            // Recursively pass through result
            return try convertToValidObject(dateVal)
        }
        
        // -- Array, Dictionary, or Complex
        // Objects represented as dictionary or array.
        
        // Dictionary
        // IMPORTANT: Check dictionary first since both Dictionary and Array adhere to SGYCollectionReflection due to the SequenceType extension.
        if let dictionary = object as? SGYDictionaryReflection {
            // Skip empty dictionaries
            let validDict = try convertToValidDictionary(dictionary)
            return validDict.count > 0 ? validDict : nil
        }
        
        // Collection
        if let collection = object as? SGYCollectionReflection {
            // Skip empty collections
            let array = try convertToValidCollection(collection)
            return array.count > 0 ? array : nil
        }
        
        // Complex object
        if let serializable = object as? AnyObject {
            // Skip empty dictionaries
            let objDict = try convertToValidDictionary(serializable)
            return objDict.count > 0 ? objDict : nil
        }
        
        // -- Otherwise invalid
        // The object cannot be converted as-is.  Check for a proxy or fallthrough to alternative.
        
        // Proxy object
        if let proxy = object as? SGYJSONProxyConvertible {
            return try convertToValidObject(proxy.jsonProxy)
        }
        
        // Fell through.  If strict mode throw.
        if strictMode { throw SGYSerializationError.InvalidObject(object) }
        return nil
    }

    private func unwrap(any: Any) -> Any? {
        // If not optional return value
        guard let optional = any as? SGYOptionalReflection else { return any }
        // Must wrap a non-nil
        guard let wrappedValue = optional.wrappedValue else { return nil }
        // Could have returned Optional as the non-nil, so recursively call again
        return unwrap(wrappedValue)
    }
}