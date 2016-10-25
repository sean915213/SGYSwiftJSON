//
//  JSONWarnings.swift
//  Pods
//
//  Created by Sean G Young on 10/25/16.
//
//

import Foundation


/// A protocol defining a single method that can communicate JSON conversion warnings.
public protocol JSONWarningObserver {
    
    /// This method is called whenever a warning is encountered during JSON conversion.
    ///
    /// - Parameter warning: A `JSONWarning` case describing the issue.
    func observe(warning: JSONWarning)
}

/**
 Warnings recorded during JSON conversion.
 
 - unsupportedConversion(`Any.Type`, `Any.Type`): A case that indicates the first type could not be converted to the second type.
 - unsupportedDictionaryKeyType(`Any.Type`): A dictionary was encountered with an invalid type of key.
 - keyValueError(`String`, `Any`, `NSError`): An error was thrown using KVC to assign a property to an object.
 */
public enum JSONWarning {
    /**
     A case that indicates the first type could not be converted to the second type.
     
     - returns: A `Warning` case containing the JSON type and the type that it could not be converted to.
     */
    case unsupportedConversion(Any.Type, Any.Type)
    /**
     A dictionary was encountered with an invalid type of key.
     
     - returns: A `Warning` case containing the offending type.
     */
    case unsupportedDictionaryKeyType(Any.Type)
    /**
     An error was thrown using KVC to assign a property to an object.
     
     - returns: A `Warning` case containing the name of the property, the value being assigned that raised the error, and the error itself.
     */
    case keyValueError(String, Any, NSError)
}
