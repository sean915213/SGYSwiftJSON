//
//  SGYJSONSerialization.swift
//  SGYSwiftJSON
//
//  Created by Sean Young on 9/11/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import Foundation

public typealias SGYJSONDateConversionBlock = (AnyObject) -> Date?
public typealias SGYJSONUnsupportedConversionBlock = (AnyObject, Any.Type) -> Void

/// A JSON deserializer.
public class SGYJSONDeserializer {
    
    /**
     Errors thrown during deserialization.
     
     - InvalidDeserializedObject: The provided data deserialized into an object incompatible with the type argument.
     - KeyValueError(`String`, `AnyObject`, `NSError`): An error was thrown calling `setValue:property:` on the deserialized object.
     - NSJSONDeserializationError(`NSError`): An error was thrown when deserializing the initial data.
     */
    public enum DeserializeError: Error {
        /**
         Indicates the provided data deserialized into an object incompatible with the type argument.
         
         - returns: An `Error` case.
         */
        case invalidDeserializedObject,
        
        /**
        An error was thrown calling `setValue:property:` on the deserialized object.
        
        - returns: An `Error` case.
        */
        keyValueError(String, AnyObject, NSError),
        
        /**
        An error was thrown when deserializing the initial data.
        
        - returns: An `Error` case.
        */
        nsjsonDeserializationError(NSError)
    }
    
    // MARK: - Initialization
    
    /**
    Initializes a new instance.
    
    - returns: An `SGYJSONDeserializer` instance.
    */
    public init() { }

    // MARK: - Properties
    
    /// If a `Date` property is encountered during deserialization this block is used to convert the deserialized value.
    public var dateConversionBlock: SGYJSONDateConversionBlock?
    /// The reading options used during deserialization.
    public var readingOptions = JSONSerialization.ReadingOptions()
    /// If provided this block is invoked whenever an encountered deserialized value could not be assigned.
    public var unsupportedConversionBlock: SGYJSONUnsupportedConversionBlock?
    
    // MARK: - Methods
    // MARK: Public
    
    /**
    Creates an instance of the provided `JSONKeyValueCreatable` type and attempts assigning its properties using the provided JSON data.
    
    - parameter jsonData: JSON data.
    
    - throws: All `SGYJSONDeserializer.Error` cases.
    
    - returns: An instance of the provided `JSONKeyValueCreatable` type with the associated deserialized properties assigned.
    */
    public func deserialize<T: JSONKeyValueCreatable>(_ jsonData: Data) throws -> T {
        // Create an instance
        let instance = T()
        // Deserialize properties into object and return
        try deserialize(jsonData, intoInstance: instance)
        return instance
    }
    
    /**
     Attempts assigning properties to the provided `JSONKeyValueCreatable` instance using the provided JSON data.
     
     - parameter jsonData: JSON data.
     - parameter instance: An object instance conforming to `JSONKeyValueCreatable`.
     
     - throws: All `SGYJSONDeserializer.Error` types.
     */
    public func deserialize(_ jsonData: Data, intoInstance instance: JSONKeyValueCreatable) throws {
        // Deserialize data
        let jsonObject = try deserializeData(jsonData)
        // Result can only be a dictionary or an array, and we only expect a dictionary in this scenario
        guard let dictionary = jsonObject as? [String: AnyObject] else { throw DeserializeError.invalidDeserializedObject }
        // Assign properties from dictionary and return
        try assignInstanceProperties(instance, dictionary: dictionary)
    }
    
    /**
     Creates an instance of the provided `JSONCollectionCreatable` type and attempts assigning its elements using the provided JSON data.
     
     - parameter jsonData: JSON data.
     
     - throws: All `SGYJSONDeserializer.Error` types.
     
     - returns: An instance of the provided `JSONCollectionCreatable` type with the associated deserialized elements assigned.
     */
    public func deserialize<T: JSONCollectionCreatable>(_ jsonData: Data) throws -> T {
        // Deserialize data
        let jsonObject = try deserializeData(jsonData)
        // Result can only be a dictionary or an array, and we only expect an array in this scenario
        guard let array = jsonObject as? [AnyObject] else { throw DeserializeError.invalidDeserializedObject }
        // Return converted collection
        return try convertCollection(array, toCollectionType: T.self) as! T
    }
    
    /**
     Creates an instance of the provided `JSONDictionaryCreatable` type and attempts assigning its key-value pairs using the provided JSON data.
     
     - parameter jsonData: JSON data.
     
     - throws: All `SGYJSONDeserializer.Error` types.
     
     - returns: An instance of the provided `JSONDictionaryCreatable` type with the associated key-value pairs assigned.
     */
    public func deserialize<T: JSONDictionaryCreatable>(_ jsonData: Data) throws -> T {
        // Deserialize data
        let jsonObject = try deserializeData(jsonData)
        // Result can only be a dictionary or an array, and we only expect a dictionary in this scenario
        guard let dictionary = jsonObject as? [String: AnyObject] else { throw DeserializeError.invalidDeserializedObject }
        return try convertDictionary(dictionary, toDictionaryType: T.self) as! T
    }
    
    // MARK: Private
    
    private func deserializeData(_ data: Data) throws -> AnyObject {
        do { return try JSONSerialization.jsonObject(with: data, options: readingOptions) as AnyObject }
        catch let e as NSError { throw DeserializeError.nsjsonDeserializationError(e) }
    }
    
    private func convertCollection(_ values: [AnyObject], toCollectionType type: JSONCollectionCreatable.Type) throws -> JSONCollectionCreatable {
        // First collect all converted values.  MUST collect into an array typed of [AnyObject] because in the end that's what we must return from this function.  Returning [Any] completely breaks the ability to assign the resultant objects.
        let convertedValues: [AnyObject?] = try values.map { try self.convertValue($0, toType: type.elementType) as? AnyObject }
        // Create a filtered list of non-nil, unwrapped values
        let realValues = (convertedValues.filter { $0 != nil }).map { $0! }
        // Return a type instance initialized with the contents
        return type.init(array: realValues)
    }
    
    private func convertDictionary(_ dictionary: [String: AnyObject], toDictionaryType type: JSONDictionaryCreatable.Type) throws -> JSONDictionaryCreatable {
        var typedDictionary = [String: AnyObject]()
        for (key, value) in dictionary {
            if let typedValue = try convertValue(value, toType: type.keyValueTypes.value) as? AnyObject { typedDictionary[key] = typedValue }
        }
        // Return a type instance initialized with the contents
        return type.init(dictionary: typedDictionary)
    }

    private func convertValue(_ value: AnyObject, toType: Any.Type) throws -> Any? {
        var type = toType
        // Unwrap all optional nesting on the type
        type = unwrap(type)
        // If requested type is already AnyObject or both types are explicitly equal return raw value
        guard type != AnyObject.self && type != type(of: value) else { return value }
        
        // Since Date conversion is supplied via a block check for this property type first and pass to block.
        // 99% of the time a JSON date is a number or string, but checking this first is trivial performance-wise and allows conversions to date with all types produced by JSONSerialization.
        if type is Date.Type { return dateConversionBlock?(value) }
        
        // Check where value is a leaf value
        if let leafValue = JSONLeafValue(object: value) {
            // Check special cases
            switch leafValue {
            case .string(let string): if type is NSString.Type { return string }
            case .number(let number): if type is NSNumber.Type { return number }
            case .null(_): return nil
            }
            // Type must support conversion from leaf value or return nil
            guard let leafCreatable = type as? JSONLeafCreatable.Type else { return nil }
            return leafCreatable.init(jsonValue: leafValue)
        }
        
        // Block that logs this conversion as invalid
        let unsupportedConversion = { self.unsupportedConversionBlock?(value, type) }
        
        // ARRAY. Check whether the returned value is an NSArray (always the case from JSONSerialization for any collection type)
        if let arrayValue = value as? [AnyObject] {
            // Limited backwards compatibility
            if type is NSArray.Type {
                if type is NSMutableArray.Type { return (arrayValue as NSArray).mutableCopy() }
                return arrayValue
            }
            
            // Check whether property adheres to our collection protocol
            if let collectionType = type as? JSONCollectionCreatable.Type {
                // Return converted collection
                return try convertCollection(arrayValue, toCollectionType: collectionType)
            } else {
                // JSON value was an array but property does not adhere to sequence protocol.
                unsupportedConversion()
                return nil
            }
        }
        
        // DICTIONARY. Check whether the returned value is an NSDictionary (always the case from JSONSerialization for any dictionary/complex type).
        if let dictionaryValue = value as? [String: AnyObject] {
            // Limited backwards compatibility
            if type is NSDictionary.Type {
                if type is NSMutableDictionary.Type { return (dictionaryValue as NSDictionary).mutableCopy() }
                return dictionaryValue
            }
            
            // Check whether property type adheres to our protocol
            if let assignableType = type as? JSONKeyValueCreatable.Type {
                let instance = assignableType.init()
                try assignInstanceProperties(instance, dictionary: dictionaryValue)
                // Return instance
                return instance
            } else if let dictionaryType = type as? JSONDictionaryCreatable.Type {
                // Currently only capable of converting dictionaries with string keys
                if dictionaryType.keyValueTypes.key != String.self {
                    // Property is a dictionary type but key type is not string.  Do not have a good way to support this yet.
                    unsupportedConversion()
                } else {
                    // Convert dictionary's values to specified type
                    return try convertDictionary(dictionaryValue, toDictionaryType: dictionaryType)
                }
            }
        }
        
        // Execute unsupported conversion block
        unsupportedConversion()
        return nil
    }
    
    private func assignInstanceProperties(_ instance: JSONKeyValueCreatable, dictionary: [String: AnyObject]) throws {
        var instanceMirror: Mirror? = Mirror(reflecting: instance)
        while let mirror = instanceMirror {
            // Loop through the instance's property info
            for property in mirror.children {
                // Check whether dictionary contains a value for this property
                guard let name = property.label, let propertyValue = dictionary[name] else { continue }
                // Get the property's declared type
                let propertyType: Any.Type = Mirror(reflecting: property.value).subjectType
                
                // Attempt converting the property's value
                guard let converted = try convertValue(propertyValue, toType: propertyType) else { continue }
                // Try setting the value
                do { try instance.setValue(converted, property: name) }
                catch let e as NSError { throw DeserializeError.keyValueError(name, propertyValue, e) }
            }
            // Delve into superclass mirror
            instanceMirror = mirror.superclassMirror
        }
    }
    
    private func unwrap(_ type: Any.Type) -> Any.Type {
        if let optionalType = type as? SGYOptionalReflection.Type { return unwrap(optionalType.wrappedType) }
        return type
    }
}
