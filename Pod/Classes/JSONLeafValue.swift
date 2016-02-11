//
//  JSONLeafValue.swift
//  SGYSwiftJSON
//
//  Created by Sean G Young on 1/28/16.
//
//

import Foundation

/**
 Describes the possible leaf values that `NSJSONSerialization` will serialize or deserialize.
 
 - String:              A JSON String. Represented as an `NSString` value.
 - Number:              A JSON Number. Represented as an `NSNumber` value.
 - Null:                A JSON null. Represented as an `NSNull` value.
 */
public enum JSONLeafValue {
    /// Represents a JSON String leaf value.  Wraps an `NSString` value.
    case String(NSString),
    /// Represents a JSON Number leaf value.  Wraps an `NSNumber` value.
    Number(NSNumber),
    /// Represents a JSON null leaf value.  Wraps an `NSNull` value.
    Null(NSNull)
    
    /**
     Initializes a `String` case with an `NSString` value.
     
     - parameter string: An `NSString`.
     
     - returns: A `String` case containing an `NSString` value.
     */
    public init(_ string: NSString) {
        self = String(string)
    }
    
    /**
     Initializes a `Null` case with an `NSNull` value.
     
     - parameter string: An `NSNull`.
     
     - returns: A `Null` case containing an `NSNull` value.
     */
    public init(_ null: NSNull) {
        self = Null(null)
    }
    
    /**
     Attempts initializing a `Number` case with an `NSNumber` value. The number's `doubleValue` cannot be NaN or infinite. In these cases `nil` is returned.
     
     - parameter number: An `NSNumber` value.
     
     - returns: A `Number` case containing an `NSNumber` value, or `nil` if `number` did not meet requirements.
     */
    public init?(_ number: NSNumber) {
        // Per documentation NSJSONSerialization will fail on NaN and infinite numbers
        guard !number.doubleValue.isNaN && !number.doubleValue.isInfinite else { return nil }
        self = Number(number)
    }
    
    init?(object: AnyObject) {
        if let string = object as? NSString { self.init(string) }
        else if let number = object as? NSNumber { self.init(number) }
        else if let null = object as? NSNull { self.init(null) }
        else { return nil }
    }
    
    var value: AnyObject {
        switch self {
        case String(let string): return string
        case Number(let number): return number
        case Null(let null): return null
        }
    }
}
