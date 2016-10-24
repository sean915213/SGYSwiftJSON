//
//  SGYJSONSerialization.swift
//  SGYSwiftJSON
//
//  Created by Sean Young on 9/11/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import Foundation

public typealias SGYJSONDateConversionBlock = (Any) -> Date?
public typealias SGYJSONUnsupportedConversionBlock = (Any, Any.Type) -> Void

/// A JSON deserializer.
public class SGYJSONDeserializer {
    
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
    
    // MARK: - Methods
    // MARK: Public
    
    /**
    Creates an instance of the provided `JSONKeyValueCreatable` type and attempts assigning its properties using the provided JSON data.
    
    - parameter jsonData: JSON data.
    
    - throws: All `SGYJSONDeserializer.DeserializeError` cases.
    
    - returns: A tuple containing an instance of the provided `JSONKeyValueCreatable` type with the associated deserialized properties assigned and a list of `SGYJSONSerializer.Warning` cases if any were encountered.
    */
    public func deserialize<T: JSONKeyValueCreatable>(_ jsonData: Data) throws -> (T, [Warning]?) {
        // Create an instance
        let instance = T()
        // Deserialize properties into object and return
        return (instance, try deserialize(jsonData, intoInstance: instance))
    }
    
    /**
     Attempts assigning properties to the provided `JSONKeyValueCreatable` instance using the provided JSON data.
     
     - parameter jsonData: JSON data.
     - parameter instance: An object instance conforming to `JSONKeyValueCreatable`.
     
     - throws: All `SGYJSONDeserializer.DeserializeError` types.
     
     - returns: A list of `SGYJSONSerializer.Warning` cases if any were encountered.
     */
    @discardableResult
    public func deserialize(_ jsonData: Data, intoInstance instance: JSONKeyValueCreatable) throws -> [Warning]? {
        // Deserialize data
        let jsonObject = try deserializeData(jsonData)
        // Result can only be a dictionary or an array, and we only expect a dictionary in this scenario
        guard let dictionary = jsonObject as? [String: Any] else { throw DeserializeError.invalidDeserializedObject(type(of: jsonObject), [String: Any].self) }
        // Assign properties from dictionary and return
        return assignInstanceProperties(instance, dictionary: dictionary)
    }
    
    /**
     Creates an instance of the provided `JSONCollectionCreatable` type and attempts assigning its elements using the provided JSON data.
     
     - parameter jsonData: JSON data.
     
     - throws: All `SGYJSONDeserializer.DeserializeError` types.
     
     - returns: A tuple containing an instance of the provided `JSONCollectionCreatable` type with the associated deserialized elements assigned and a list of `SGYJSONSerializer.Warning` cases if any were encountered.
     */
    public func deserialize<T: JSONCollectionCreatable>(_ jsonData: Data) throws -> (T, [Warning]?) {
        // Deserialize data
        let jsonObject = try deserializeData(jsonData)
        // Result can only be a dictionary or an array, and we only expect an array in this scenario
        guard let array = jsonObject as? [Any] else { throw DeserializeError.invalidDeserializedObject(type(of: jsonObject), [Any].self) }
        // Return converted collection
        let (converted, warnings) = convertCollection(array, toCollectionType: T.self)
        return (converted as! T, warnings)
    }
    
    /**
     Creates an instance of the provided `JSONDictionaryCreatable` type and attempts assigning its key-value pairs using the provided JSON data.
     
     - parameter jsonData: JSON data.
     
     - throws: All `SGYJSONDeserializer.DeserializeError` types.
     
     - returns: A tuple containing an instance of the provided `JSONDictionaryCreatable` type with the associated key-value pairs assigned and a list of `SGYJSONSerializer.Warning` cases if any were encountered.
     */
    public func deserialize<T: JSONDictionaryCreatable>(_ jsonData: Data) throws -> (T, [Warning]?) {
        // Deserialize data
        let jsonObject = try deserializeData(jsonData)
        // Result can only be a dictionary or an array, and we only expect a dictionary in this scenario
        guard let dictionary = jsonObject as? [String: Any] else { throw DeserializeError.invalidDeserializedObject(type(of: jsonObject), [String: Any].self) }
        let (converted, warnings) = convertDictionary(dictionary, toDictionaryType: T.self)
        return (converted as! T, warnings)
    }
    
    // MARK: Private
    
    private func deserializeData(_ data: Data) throws -> Any {
        do { return try JSONSerialization.jsonObject(with: data, options: readingOptions) }
        catch let e as NSError { throw DeserializeError.jsonDeserializationError(e) }
    }
    
    private func convertCollection(_ values: [Any], toCollectionType type: JSONCollectionCreatable.Type) -> (JSONCollectionCreatable?, [Warning]?) {
        // First collect all converted values.
        
        var allWarnings = [Warning]()
        var convertedValues = [Any]()
        for i in 0..<values.count {
            let value = values[i]
            // Attempt converting
            let (converted, warnings) = convertValue(value, toType: type.elementType)
            // If converted value returned add to all
            if let converted = converted { convertedValues.append(converted) }
            // If any warnings exist create assignment warning and add
            if let warnings = warnings {
                let assignWarning = Warning.assignment(String(i), warnings)
                allWarnings.append(assignWarning)
            }
        }
        // Return a type instance initialized with the contents
        return (type.init(array: convertedValues), allWarnings.isEmpty ? nil : allWarnings)
    }
    
    private func convertDictionary(_ dictionary: [String: Any], toDictionaryType type: JSONDictionaryCreatable.Type) -> (JSONDictionaryCreatable?, [Warning]?) {
        var allWarnings = [Warning]()
        var typedDictionary = [String: Any]()
        for (key, value) in dictionary {
            let (convertedValue, warnings) = convertValue(value, toType: type.keyValueTypes.value)
            // If converted value returned then assign
            if let converted = convertedValue { typedDictionary[key] = converted }
            // If any warnings exist create assignment warning and add
            if let warnings = warnings {
                let assignWarning = Warning.assignment(key, warnings)
                allWarnings.append(assignWarning)
            }
        }
        // Return a type instance initialized with the contents
        return (type.init(dictionary: typedDictionary), allWarnings.isEmpty ? nil : allWarnings)
    }

    private func convertValue(_ value: Any, toType: Any.Type) -> (Any?, [Warning]?) {
        
        // Block for easily returning clean results
        let clean: (Any?) -> (Any?, [Warning]?) = { (result: Any?) in return (result, nil) }
        
        // Unwrap all optional nesting on the type
        var type = toType
        type = unwrap(type)
        
        // If requested type is already Any, AnyObject or both types are explicitly equal return raw value
        guard type != Any.self && type != AnyObject.self && type != type(of: value) else { return clean(value) }
        
        // Since Date conversion is supplied via a block check for this property type first and pass to block.
        // 99% of the time a JSON date is a number or string, but checking this first is trivial performance-wise and allows conversions to date with all types produced by JSONSerialization.
        if type is Date.Type { return clean(dateConversionBlock?(value)) }
        
        // Check whether value is a leaf value
        if let leafValue = JSONLeafValue(object: value) {
            // Check special cases
            switch leafValue {
            case .string(let string): if type is NSString.Type { return (string, nil) }
            case .number(let number): if type is NSNumber.Type { return (number, nil) }
            case .null(_): return (nil, nil)
            }
            // Type must support conversion from leaf value or return nil
            guard let leafCreatable = type as? JSONLeafCreatable.Type else { return (nil, nil) }
            return clean(leafCreatable.init(jsonValue: leafValue))
        }
        
        // Block that logs this conversion as invalid
        //let unsupportedConversion = { (bridgingProtocol: Any.Type) in self.unsupportedConversionBlock?(value, type) }
        
        let conversionWarn: () -> (Any?, [Warning]?) = { (nil, [Warning.unsupportedConversion(type(of: value), toType)]) }
        
        
        // ARRAY. Check whether the returned value is an NSArray (always the case from JSONSerialization for any collection type)
        if let arrayValue = value as? [Any] {
            // Limited backwards compatibility
            if type is NSArray.Type {
                if type is NSMutableArray.Type { return clean((arrayValue as NSArray).mutableCopy()) }
                return clean(arrayValue)
            }
            
            // Check whether property adheres to our collection protocol
            if let collectionType = type as? JSONCollectionCreatable.Type {
                // Two-line syntax avoids compiler error
                let (collection, warnings) = convertCollection(arrayValue, toCollectionType: collectionType)
                return (collection, warnings)
            } else {
                // JSON value was an array but property does not adhere to sequence protocol.
                return conversionWarn()
            }
        }
        
        // DICTIONARY. Check whether the returned value is [String: Any] type (always the case from JSONSerialization for any dictionary/complex type).
        if let dictionaryValue = value as? [String: Any] {
            // Limited backwards compatibility
            if type is NSDictionary.Type {
                if type is NSMutableDictionary.Type { return clean((dictionaryValue as NSDictionary).mutableCopy()) }
                return clean(dictionaryValue)
            }
            
            // Check whether property type adheres to our protocol
            if let assignableType = type as? JSONKeyValueCreatable.Type {
                let instance = assignableType.init()
                try assignInstanceProperties(instance, dictionary: dictionaryValue)
                // Return instance
                return clean(instance)
            } else if let dictionaryType = type as? JSONDictionaryCreatable.Type {
                // Currently only capable of converting dictionaries with string keys
                if dictionaryType.keyValueTypes.key != String.self {
                    // Property is a dictionary type but key type is not string.  Do not have a good way to support this yet.
                    let keyWarning = Warning.unsupportedDictionaryKeyType(dictionaryType.keyValueTypes.key)
                    return (nil, [keyWarning])
                } else {
                    // Two-line syntax avoids compiler error
                    let (dictionary, warnings) = convertDictionary(dictionaryValue, toDictionaryType: dictionaryType)
                    return (dictionary, warnings)
                }
            }
        }
        
        // Return unsupported conversion warning
        return conversionWarn()
    }
    
    private func assignInstanceProperties(_ instance: JSONKeyValueCreatable, dictionary: [String: Any]) -> [Warning]? {
        var instanceMirror: Mirror? = Mirror(reflecting: instance)
        var allWarnings = [Warning]()
        while let mirror = instanceMirror {
            // Loop through the instance's property info
            for property in mirror.children {
                // Check whether dictionary contains a value for this property
                guard let name = property.label, let propertyValue = dictionary[name] else { continue }
                // Get the property's declared type
                let propertyType: Any.Type = Mirror(reflecting: property.value).subjectType
                
                // Attempt converting the property's value
                let (convertedValue, warnings) = convertValue(propertyValue, toType: propertyType)
                // If any warnings add as assignment
                if let warnings = warnings { allWarnings.append(.assignment(name, warnings)) }
                // If no value continue
                guard let converted = convertedValue else { continue }
                // Try setting the value
                do {
                    try instance.setValue(converted, property: name)
                } catch let e as NSError {
                    // Add to warnings
                    allWarnings.append(.keyValueError(name, propertyValue, e))
                }
            }
            // Delve into superclass mirror
            instanceMirror = mirror.superclassMirror
        }
        // Return warnings
        return allWarnings.isEmpty ? nil : allWarnings
    }
    
    private func unwrap(_ type: Any.Type) -> Any.Type {
        if let optionalType = type as? SGYOptionalReflection.Type { return unwrap(optionalType.wrappedType) }
        return type
    }
}

extension SGYJSONDeserializer {
    
    
    /**
     Errors thrown during deserialization.
     
     - invalidDeserializedObject(`Any.Type`, `Any.Type`): The provided data deserialized into an object incompatible with the type argument.
     - keyValueError(`String`, `Any`, `NSError`): An error was thrown calling `setValue:property:` on the deserialized object.
     - jsonDeserializationError(`NSError`): An error was thrown when deserializing the initial data.
     */
    public enum DeserializeError: Error {
        /**
         Indicates the provided data deserialized into an object incompatible with the type argument.
         
         - returns: An `Error` case.
         */
        case invalidDeserializedObject(Any.Type, Any.Type)
        
        /**
         An error was thrown calling `setValue:property:` on the deserialized object.
         
         - returns: An `Error` case.
         */
        case keyValueError(String, Any, NSError)
        
        /**
         An error was thrown when deserializing the initial data.
         
         - returns: An `Error` case.
         */
        case jsonDeserializationError(NSError)
    }
    
    /**
     Warnings recorded during deserialization.
     
     - unsupportedConversion(`Any.Type`, `Any.Type`): The resulting JSON type could not be converted into the native type.
     - assignment(`String`, `[Warning]`): There was a problem deserializing and assigning a specific property.
     - unsupportedDictionaryKeyType(`Any.Type`): A dictionary was encountered with an invalid type of key.
     - keyValueError(`String`, `Any`, `NSError`): An error was thrown using KVC to assign a property to an object.
     */
    public enum Warning {
        /**
         The resulting JSON type could not be converted into the native type.
         
         - returns: A `Warning` case.
         */
        case unsupportedConversion(Any.Type, Any.Type)
        /**
         There was a problem deserializing and assigning a specific property.
         
         - returns: A `Warning` case.
         */
        indirect case assignment(String, [Warning])
        /**
         A dictionary was encountered with an invalid type of key.
         
         - returns: A `Warning` case.
         */
        case unsupportedDictionaryKeyType(Any.Type)
        /**
         An error was thrown using KVC to assign a property to an object.
         
         - returns: A `Warning` case.
         */
        case keyValueError(String, Any, NSError)
    }
    
    /**
     Creates an instance of the provided `JSONKeyValueCreatable` type and attempts assigning its properties using the provided JSON data.
     
     - parameter jsonData: JSON data.
     
     - throws: All `SGYJSONDeserializer.DeserializeError` cases.
     
     - returns: An instance of the provided `JSONKeyValueCreatable` type with the associated deserialized properties assigned.
     */
    public func deserialize<T: JSONKeyValueCreatable>(_ jsonData: Data) throws -> T {
        return try deserialize(jsonData).0
    }
    
    /**
     Creates an instance of the provided `JSONCollectionCreatable` type and attempts assigning its elements using the provided JSON data.
     
     - parameter jsonData: JSON data.
     
     - throws: All `SGYJSONDeserializer.DeserializeError` types.
     
     - returns: An instance of the provided `JSONCollectionCreatable` type with the associated deserialized elements assigned.
     */
    public func deserialize<T: JSONCollectionCreatable>(_ jsonData: Data) throws -> T {
        return try deserialize(jsonData).0
    }
    
    /**
     Creates an instance of the provided `JSONDictionaryCreatable` type and attempts assigning its key-value pairs using the provided JSON data.
     
     - parameter jsonData: JSON data.
     
     - throws: All `SGYJSONDeserializer.DeserializeError` types.
     
     - returns: An instance of the provided `JSONDictionaryCreatable` type with the associated key-value pairs assigned.
     */
    public func deserialize<T: JSONDictionaryCreatable>(_ jsonData: Data) throws -> T {
        return try deserialize(jsonData).0
    }
}
