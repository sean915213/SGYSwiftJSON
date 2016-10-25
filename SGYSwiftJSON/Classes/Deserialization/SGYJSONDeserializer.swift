//
//  SGYJSONSerialization.swift
//  SGYSwiftJSON
//
//  Created by Sean Young on 9/11/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import Foundation

public typealias SGYJSONDateConversionBlock = (Any) -> Date?

/// A JSON deserializer.
open class SGYJSONDeserializer {
    
    // MARK: - Initialization
    
    /**
    Initializes a new instance.
    
    - returns: An `SGYJSONDeserializer` instance.
    */
    public init() { }

    // MARK: - Properties
    
    /// If a `Date` property is encountered during deserialization this block is used to convert the deserialized value.
    open var dateConversionBlock: SGYJSONDateConversionBlock?
    /// The reading options used during deserialization.
    open var readingOptions = JSONSerialization.ReadingOptions()
    
    // MARK: - Methods
    // MARK: Public
    
    /**
    Creates an instance of the provided `JSONKeyValueCreatable` type and attempts assigning its properties using the provided JSON data.
    
    - parameter jsonData: JSON data.
    
    - throws: All `SGYJSONDeserializer.DeserializeError` cases.
    
    - returns: An instance of the provided `JSONKeyValueCreatable` type with the associated deserialized properties assigned.
    */
    open func deserialize<T: JSONKeyValueCreatable>(_ jsonData: Data, observer: JSONWarningObserver? = nil) throws -> T {
        // Create an instance
        let instance = T()
        // Deserialize properties into object and return
        try deserialize(jsonData, intoInstance: instance, observer: observer)
        return instance
    }
    
    /**
     Attempts assigning properties to the provided `JSONKeyValueCreatable` instance using the provided JSON data.
     
     - parameter jsonData: JSON data.
     - parameter instance: An object instance conforming to `JSONKeyValueCreatable`.
     
     - throws: All `SGYJSONDeserializer.DeserializeError` types.
     */
    open func deserialize(_ jsonData: Data, intoInstance instance: JSONKeyValueCreatable, observer: JSONWarningObserver? = nil) throws {
        // Deserialize data
        let jsonObject = try deserializeData(jsonData)
        // Result can only be a dictionary or an array, and we only expect a dictionary in this scenario
        guard let dictionary = jsonObject as? [String: Any] else { throw DeserializeError.invalidDeserializedObject(type(of: jsonObject), [String: Any].self) }
        // Assign properties from dictionary and return
        return assignInstanceProperties(instance, dictionary: dictionary, observer: observer)
    }
    
    /**
     Creates an instance of the provided `JSONCollectionCreatable` type and attempts assigning its elements using the provided JSON data.
     
     - parameter jsonData: JSON data.
     
     - throws: All `SGYJSONDeserializer.DeserializeError` types.
     
     - returns: An instance of the provided `JSONCollectionCreatable` type with the associated deserialized elements assigned.
     */
    open func deserialize<T: JSONCollectionCreatable>(_ jsonData: Data, observer: JSONWarningObserver? = nil) throws -> T {
        // Deserialize data
        let jsonObject = try deserializeData(jsonData)
        // Result can only be a dictionary or an array, and we only expect an array in this scenario
        guard let array = jsonObject as? [Any] else { throw DeserializeError.invalidDeserializedObject(type(of: jsonObject), [Any].self) }
        // Return converted collection
        return convertCollection(array, toCollectionType: T.self, observer: observer) as! T
    }
    
    /**
     Creates an instance of the provided `JSONDictionaryCreatable` type and attempts assigning its key-value pairs using the provided JSON data.
     
     - parameter jsonData: JSON data.
     
     - throws: All `SGYJSONDeserializer.DeserializeError` types.
     
     - returns: An instance of the provided `JSONDictionaryCreatable` type with the associated key-value pairs assigned.
     */
    open func deserialize<T: JSONDictionaryCreatable>(_ jsonData: Data, observer: JSONWarningObserver? = nil) throws -> T {
        // Deserialize data
        let jsonObject = try deserializeData(jsonData)
        // Result can only be a dictionary or an array, and we only expect a dictionary in this scenario
        guard let dictionary = jsonObject as? [String: Any] else { throw DeserializeError.invalidDeserializedObject(type(of: jsonObject), [String: Any].self) }
        return convertDictionary(dictionary, toDictionaryType: T.self, observer: observer) as! T
    }
    
    // MARK: Private
    
    private func deserializeData(_ data: Data) throws -> Any {
        do { return try JSONSerialization.jsonObject(with: data, options: readingOptions) }
        catch let e as NSError { throw DeserializeError.jsonDeserializationError(e) }
    }
    
    private func convertCollection(_ values: [Any], toCollectionType type: JSONCollectionCreatable.Type, observer: JSONWarningObserver?) -> JSONCollectionCreatable? {
        // First collect all converted values.
        var convertedValues = [Any]()
        for i in 0..<values.count {
            let value = values[i]
            // Attempt converting
            let converted = convertValue(value, toType: type.elementType, observer: observer)
            // If converted value returned add to all
            if let converted = converted { convertedValues.append(converted) }
        }
        // Return a type instance initialized with the contents
        return type.init(array: convertedValues)
    }
    
    private func convertDictionary(_ dictionary: [String: Any], toDictionaryType type: JSONDictionaryCreatable.Type, observer: JSONWarningObserver?) -> JSONDictionaryCreatable? {
        var typedDictionary = [String: Any]()
        for (key, value) in dictionary {
            let convertedValue = convertValue(value, toType: type.keyValueTypes.value, observer: observer)
            // If converted value returned then assign
            if let converted = convertedValue { typedDictionary[key] = converted }
        }
        // Return a type instance initialized with the contents
        return type.init(dictionary: typedDictionary)
    }

    private func convertValue(_ value: Any, toType: Any.Type, observer: JSONWarningObserver?) -> Any? {
        // Unwrap all optional nesting on the type
        var type = toType
        type = unwrap(type)
        
        // If requested type is already Any, AnyObject or both types are explicitly equal return raw value
        guard type != Any.self && type != AnyObject.self && type != type(of: value) else { return value }
        
        // Since Date conversion is supplied via a block check for this property type first and pass to block.
        // 99% of the time a JSON date is a number or string, but checking this first is trivial performance-wise and allows conversions to date with all types produced by JSONSerialization.
        if type is Date.Type { return dateConversionBlock?(value) }
        
        // Check whether value is a leaf value
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
        
        // Block that indicates this conversion is invalid
        let conversionWarn = { observer?.observe(warning: .unsupportedConversion(type(of: value), toType)) }
        
        // ARRAY. Check whether the returned value is an NSArray (always the case from JSONSerialization for any collection type)
        if let arrayValue = value as? [Any] {
            // Limited backwards compatibility
            if type is NSArray.Type {
                if type is NSMutableArray.Type { return (arrayValue as NSArray).mutableCopy() }
                return arrayValue
            }
            
            // Check whether property adheres to our collection protocol
            if let collectionType = type as? JSONCollectionCreatable.Type {
                // Two-line syntax avoids compiler error
                return convertCollection(arrayValue, toCollectionType: collectionType, observer: observer)
            } else {
                // JSON value was an array but property does not adhere to sequence protocol.
                conversionWarn()
                return nil
            }
        }
        
        // DICTIONARY. Check whether the returned value is [String: Any] type (always the case from JSONSerialization for any dictionary/complex type).
        if let dictionaryValue = value as? [String: Any] {
            // Limited backwards compatibility
            if type is NSDictionary.Type {
                if type is NSMutableDictionary.Type { return (dictionaryValue as NSDictionary).mutableCopy() }
                return dictionaryValue
            }
            
            // Check whether property type adheres to our protocol
            if let assignableType = type as? JSONKeyValueCreatable.Type {
                let instance = assignableType.init()
                assignInstanceProperties(instance, dictionary: dictionaryValue, observer: observer)
                // Return instance
                return instance
            } else if let dictionaryType = type as? JSONDictionaryCreatable.Type {
                // Currently only capable of converting dictionaries with string keys
                if dictionaryType.keyValueTypes.key != String.self {
                    // Property is a dictionary type but key type is not string.  Do not have a good way to support this yet.
                    observer?.observe(warning: .unsupportedDictionaryKeyType(dictionaryType.keyValueTypes.key))
                    return nil
                } else {
                    // Two-line syntax avoids compiler error
                    return convertDictionary(dictionaryValue, toDictionaryType: dictionaryType, observer: observer)
                }
            }
        }
        
        // Return unsupported conversion warning
        conversionWarn()
        return nil
    }
    
    private func assignInstanceProperties(_ instance: JSONKeyValueCreatable, dictionary: [String: Any], observer: JSONWarningObserver?) {
        var instanceMirror: Mirror? = Mirror(reflecting: instance)
        while let mirror = instanceMirror {
            // Loop through the instance's property info
            for property in mirror.children {
                // Check whether dictionary contains a value for this property
                guard let name = property.label, let propertyValue = dictionary[name] else { continue }
                // Get the property's declared type
                let propertyType: Any.Type = Mirror(reflecting: property.value).subjectType
                
                // Attempt converting the property's value. If none continue
                guard let converted = convertValue(propertyValue, toType: propertyType, observer: observer) else { continue }
                // Try setting the value
                do {
                    try instance.setValue(converted, property: name)
                } catch let e as NSError {
                    // Raise warning
                    observer?.observe(warning: .keyValueError(name, propertyValue, e))
                }
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
         
         - returns: A `DeserializeError` case.
         */
        case invalidDeserializedObject(Any.Type, Any.Type)
        /**
         An error was thrown when deserializing the initial data.
         
         - returns: A `DeserializeError` case.
         */
        case jsonDeserializationError(NSError)
    }
}
