//
//  SGYJSONSerialization.swift
//  SGYSwiftConverterTest
//
//  Created by Sean Young on 9/11/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import Foundation

typealias SGYJSONDateConversionBlock = (input: AnyObject) -> NSDate?
typealias SGYJSONUnsupportedConversionBlock = (deserializedValue: AnyObject, toType: Any.Type) -> Void

enum SGYJSONErrors : ErrorType {
    case InvalidJSONString,
    InvalidDeserializedObject,
    KeyValueException(NSError)
}

class SGYJSONDeserializer {

    // MARK: - Properties
    
    var dateConversionBlock: SGYJSONDateConversionBlock?
    var unsupportedConversionBlock: SGYJSONUnsupportedConversionBlock?
    
    // MARK: - Methods
    // MARK: Public
    
    func deserialize<T: SGYKeyValueCreatable>(jsonData: NSData) throws -> T {
        // Deserialize data
        let jsonObject = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions())
        // Result can only be a dictionary or an array, and we only expect a dictionary in this scenario
        guard let dictionary = jsonObject as? [String: AnyObject] else { throw SGYJSONErrors.InvalidDeserializedObject }
        // Create an instance
        let instance = T()
        // Assign properties from dictionary and return
        try assignInstanceProperties(instance, dictionary: dictionary)
        return instance
    }
    
    func deserialize(jsonData: NSData, intoInstance instance: SGYKeyValueCreatable) throws {
        // Deserialize data
        let jsonObject = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions())
        // Result can only be a dictionary or an array, and we only expect a dictionary in this scenario
        guard let dictionary = jsonObject as? [String: AnyObject] else { throw SGYJSONErrors.InvalidDeserializedObject }
        // Assign properties from dictionary and return
        try assignInstanceProperties(instance, dictionary: dictionary)
    }
    
    func deserialize<T: SGYCollectionCreatable>(jsonData: NSData) throws -> T {
        // Deserialize data
        let jsonObject = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions())
        // Result can only be a dictionary or an array, and we only expect an array in this scenario
        guard let array = jsonObject as? [AnyObject] else { throw SGYJSONErrors.InvalidDeserializedObject }
        // Return converted collection
        return try convertCollection(array, toCollectionType: T.self) as! T
    }
    
    func deserialize<T: SGYKeyValueCreatable>(jsonData: NSData) throws -> [String: T] {
        // Deserialize data
        let jsonObject = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions())
        // Result can only be a dictionary or an array, and we only expect a dictionary in this scenario
        guard let dictionary = jsonObject as? [String: AnyObject] else { throw SGYJSONErrors.InvalidDeserializedObject }
        return try convertDictionary(dictionary, toDictionaryType: [String: T].self) as! [String: T]
    }
    
    // MARK: Private
    
    private func convertCollection(values: [AnyObject], toCollectionType type: SGYCollectionCreatable.Type) throws -> SGYCollectionCreatable {
        // First collect all converted values.  MUST collect into an array typed of [AnyObject] because in the end that's what we must return from this function.  Returning [Any] completely breaks the ability to assign the resultant objects.
        let convertedValues: [AnyObject?] = try values.map { try self.convertValue($0, toType: type.elementType) as? AnyObject }
        // Create a filtered list of non-nil, unwrapped values
        let realValues = (convertedValues.filter { $0 != nil }).map { $0! }
        // Create an instance of the protocol's class and append the contents before returning
        var sequenceInstance = type.init()
        sequenceInstance.appendContentsOf(realValues)
        return sequenceInstance
    }
    
    private func convertDictionary(dictionary: [String: AnyObject], toDictionaryType type: SGYDictionaryCreatable.Type) throws -> SGYDictionaryCreatable {
        var typedDictionary = [String: AnyObject]()
        for (key, value) in dictionary {
            if let typedValue = try convertValue(value, toType: type.keyValueTypes.value) as? AnyObject { typedDictionary[key] = typedValue }
        }
        // Create an instance of the type and merge the contents before returning
        var dictionaryInstance = type.init()
        dictionaryInstance.mergeContentsOf(typedDictionary)
        return dictionaryInstance
    }

    private func convertValue(value: AnyObject, var toType type: Any.Type) throws -> Any? {
        // Unwrap all optional nesting on the type
        type = unwrap(type)
        // Check whether types are already equal
        guard value.dynamicType != type else { return value }
        // Block that logs this conversion as invalid
        let unsupportedConversion: () -> () = { self.unsupportedConversionBlock?(deserializedValue: value, toType: type) }
        
        // Since NSDate conversion is supplied via a block check for this property type first and pass to block.
        // 99% of the time a JSON date is a number or string, but checking this first is trivial performance-wise and allows conversions to date with all types produced by NSJSONSerialization.
        if type is NSDate.Type { return dateConversionBlock?(input: value) }
        
        // NULL. Check whether value is NSNull
        if let nullValue = value as? NSNull {
            // If the declared type is also NSNull then return null directly, otherwise return nil
            return type is NSNull.Type ? nullValue : nil
        }
        
        // ARRAY. Check whether the returned value is an NSArray (always the case from NSJSONSerialization for any collection type)
        if let arrayValue = value as? [AnyObject] {
            // Check whether property adheres to our collection protocol
            if let collectionType = type as? SGYCollectionCreatable.Type {
                // Return converted collection
                return try convertCollection(arrayValue, toCollectionType: collectionType)
                
            } else {
                // JSON value was an array but property does not adhere to sequence protocol.
                unsupportedConversion()
                return nil
            }
        }
        
        // DICTIONARY. Check whether the returned value is an NSDictionary (always the case from NSJSONSerialization for any dictionary/complex type).
        if let dictionaryValue = value as? [String: AnyObject] {
            // Check whether property type adheres to our protocol
            if let assignableType = type as? SGYKeyValueCreatable.Type {
                let instance = assignableType.init()
                try assignInstanceProperties(instance, dictionary: dictionaryValue)
                // Return instance
                return instance
            } else if let dictionaryType = type as? SGYDictionaryCreatable.Type {
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
        
        // The only remaining objects that could have been produced by NSJSONSerialization are NSNumber or NSString.
        // If types match return the original type
        if value is NSNumber && type is NSNumber.Type { return value }
        else if value is String && (type is String.Type || type is NSString.Type) { return value }
        
        // Execute unsupported conversion block
        unsupportedConversion()
        return nil
    }
    
    private func assignInstanceProperties(instance: SGYKeyValueCreatable, dictionary: [String: AnyObject]) throws {
        // Loop through the instance's property info
        for property in Mirror(reflecting: instance).children {
            // Check whether dictionary contains a value for this property
            guard let name = property.label, propertyValue = dictionary[name] else { continue }
            // Get the property's declared type
            let propertyType: Any.Type = Mirror(reflecting: property.value).subjectType
            
            // Attempt converting the property's value
            if let converted = try convertValue(propertyValue, toType: propertyType) {
                do { try instance.setValue(converted as? AnyObject, property: name) }
                catch let e as NSError { throw SGYJSONErrors.KeyValueException(e) }
            }
        }
    }
    
    private func unwrap(type: Any.Type) -> Any.Type {
        if let optionalType = type as? SGYOptionalReflection.Type { return unwrap(optionalType.wrappedType) }
        return type
    }
}

extension SGYJSONDeserializer {
    
    func deserialize<T: SGYKeyValueCreatable>(jsonString: String, encoding: NSStringEncoding = NSUTF8StringEncoding) throws -> T {
        guard let data = jsonString.dataUsingEncoding(encoding) else { throw SGYJSONErrors.InvalidJSONString }
        return try deserialize(data)
    }
    
}
