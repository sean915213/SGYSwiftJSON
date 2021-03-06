//
//  SGYJSONSerializer.swift
//  SGYSwiftJSON
//
//  Created by Sean Young on 9/25/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

/// A JSON serialization class.
open class SGYJSONSerializer {
    
    /**
     Errors thrown during serialization.
     
     - JSONSerializationError(`NSError`): An error occurred seralizing the resulting (supposedly safe) object graph.  This should probably be considered a bug.
     */
    public enum SerializeError: Error {
        /**
        Indicates an error occurred seralizing the resulting (supposedly safe) object graph.  This should probably be considered a bug.
        
        - returns: An `JSONSerializationError` case initialized with the caught `NSError`.
        */
        case jsonSerializationError(NSError)
    }

    // MARK: - Initialization
    
    /**
    Initializes a new instance.
    
    - returns: An `SGYJSONSerializer` instance.
    */
    public init() { }
    
    // MARK: - Properties
    
    /// The writing options used during serialization.
    open var writingOptions = JSONSerialization.WritingOptions()
    /// The block this instance will call in order to convert `Date` values to a valid JSON leaf value.
    open var dateConversionBlock: ((_ date: Date) -> JSONLeafValue?)?
    
    // MARK: - Methods
    // MARK: Public

    /**
    Attempts serializing all the elements within a collection implementing `SGYCollectionReflection`.
    
    - parameter collection: An object implementing `SGYCollectionReflection`.
    
    - throws: All `SGYJSONSerializer.SerializeError` types.
    
    - returns: Serialized collection JSON as `Data`.
    */
    open func serialize(_ collection: SGYCollectionReflection, observer: JSONWarningObserver? = nil) throws -> Data {
        let array = try convertToValidCollection(collection, observer: observer)
        return try serializeObject(array)
    }
    
    /**
     Attempts serializing all the elements within a dictionary implementing `SGYDictionaryReflection`.
     
     - parameter dictionary: An object implementing `SGYDictionaryReflection`.
     
     - throws: All `SGYJSONSerializer.Error` types.
     
     - returns: Serialized dictionary JSON as `NSData`.
     */
    open func serialize(_ dictionary: SGYDictionaryReflection, observer: JSONWarningObserver? = nil) throws -> Data {
        let dictionary = try convertToValidDictionary(dictionary, observer: observer)
        return try serializeObject(dictionary)
    }
    
    /**
     Attempts serializing an instance of `Any`.
     
     - parameter object: An instance of `Any`.
     
     - throws: All `SGYJSONSerializer.SerializeError` types.
     
     - returns: Serialized object JSON as `Data`.
     */
    open func serialize(_ object: Any, observer: JSONWarningObserver? = nil) throws -> Data {
        // Attempt converting object to dictionary
        let dictionary = try convertToValidDictionary(object, observer: observer)
        return try serializeObject(dictionary)
    }
    
    // MARK: Private
    
    fileprivate func serializeObject(_ object: Any) throws -> Data {
        do { return try JSONSerialization.data(withJSONObject: object, options: writingOptions) }
        catch let e as NSError { throw SerializeError.jsonSerializationError(e) }
    }
    
    fileprivate func convertToValidDictionary(_ object: Any, observer: JSONWarningObserver?) throws -> [String: Any] {
        // Converted dictionary
        var jsonDictionary = [String: Any]()
        
        var mirror: Mirror? = Mirror(reflecting: object)
        while mirror != nil {
            // Pull values from mirror children
            for child in mirror!.children {
                // Make sure property has a label (don't know when it doesn't, but it's defined optional)
                guard let property = child.label else { continue }
                // Attempt parsing value into valid type
                guard let validObject = try convertToValidObject(child.value, observer: observer) else { continue }
                // Assign to dictionary
                jsonDictionary[property] = validObject
            }
            // Assign super's mirror if any and loop back through
            mirror = mirror!.superclassMirror
        }
        
        return jsonDictionary
    }
    
    fileprivate func convertToValidCollection(_ collection: SGYCollectionReflection, observer: JSONWarningObserver?) throws -> [Any] {
        var validCollection = [Any]()
        // Get child values
        for (_, value) in Mirror(reflecting: collection).children {
            if let validObj = try convertToValidObject(value, observer: observer) { validCollection.append(validObj) }
        }
        // Return collection even if empty. Caller determines what to do.
        return validCollection
    }
    
    fileprivate func convertToValidDictionary(_ dictionary: SGYDictionaryReflection, observer: JSONWarningObserver?) throws -> [String: Any] {
        var validDict = [String: Any]()
        // Get child key-value tuples
        for (_, kvp) in Mirror(reflecting: dictionary).children {
            let tuplePair = Mirror(reflecting: kvp).children.map { $0.value }
            // A string key is required so attempt deriving one
            var key: String? = tuplePair[0] as? String
            // If not immediately a string try CustomStringConvertible
            if let stringObj = tuplePair[0] as? CustomStringConvertible, key == nil { key = stringObj.description }
            // If still nil cannot continue
            guard let validKey = key else {
                // Raise to observer
                observer?.observe(warning: .unsupportedDictionaryKeyType(type(of: key)))
                continue
            }
            
            // Assign if we receive valid result
            if let validValue = try convertToValidObject(tuplePair[1], observer: observer) { validDict[validKey] = validValue }
        }
        
        return validDict
    }
    
    fileprivate func convertToValidObject(_ any: Any, observer: JSONWarningObserver?) throws -> Any? {
        // Any could be optional but is not recognized as being able to be cast as such.  So unwrap using the protocol.
        guard let object = unwrap(any) else { return nil }
        
        // Any object could implement JSONProxyProvider to provide an alternate representation so check this first.
        if let proxyProvider = object as? JSONProxyProvider {
            // This protocol only requires Any so recursively attempt conversion on proxy object
            return try convertToValidObject(proxyProvider.jsonProxy, observer: observer)
        }
        
        // Similarly any object may implement JSONLeafRepresentable so check this next
        if let leafObject = object as? JSONLeafRepresentable {
            return leafObject.jsonLeafValue?.value
        }
        
        // Date
        if let date = object as? Date {
            return dateConversionBlock?(date)?.value
        }
        
        // -- Array, Dictionary, or Complex

        // Dictionary
        // IMPORTANT: Check dictionary first since both Dictionary and Array adhere to SGYCollectionReflection due to the SequenceType extension.
        if let dictionary = object as? SGYDictionaryReflection {
            let validDict = try convertToValidDictionary(dictionary, observer: observer)
            // Skip empty dictionaries
            if validDict.isEmpty { return nil }
            return validDict
        }
        
        // Collection
        if let collection = object as? SGYCollectionReflection {
            let array = try convertToValidCollection(collection, observer: observer)
            // Skip empty collections
            return array.isEmpty ? nil : array
        }
        
        // Complex object
        let objDict = try convertToValidDictionary(object, observer: observer)
        // Skip empty dictionaries
        return objDict.isEmpty ? nil : objDict
    }
    
    fileprivate func unwrap(_ any: Any) -> Any? {
        // If not optional return value
        guard let optional = any as? SGYOptionalReflection else { return any }
        // Must wrap a non-nil
        guard let wrappedValue = optional.wrappedValue else { return nil }
        // Could have returned Optional as the non-nil, so recursively call again
        return unwrap(wrappedValue)
    }
}
