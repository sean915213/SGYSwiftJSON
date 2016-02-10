//
//  JSONLeafValue.swift
//  Pods
//
//  Created by Sean G Young on 1/28/16.
//
//

import Foundation

/**
 Describes the possible leaf values that `NSJSONSerialization` will serialize or deserialize.
 
 - String:              An `NSString` value.
 - Number:              An `NSNumber' value.
 - Null:                An `NSNull` value.
 */
public enum JSONLeafValue {
    case String(NSString), Number(NSNumber), Null(NSNull)
    
    /**
     Initializes the enum with an `NSString` value.
     
     - parameter string: An `NSString`.
     
     - returns: An initialized enum.
     */
    public init(_ string: NSString) { self = String(string) }
    
    /**
     Initializes the enum with an `NSNull` value.
     
     - parameter string: An `NSNull`.
     
     - returns: An initialized enum.
     */
    public init(_ null: NSNull) { self = Null(null) }
    
    /**
     Attempts initializing the enum with an `NSNumber` value. This number's *doubleValue* cannot be NaN or Infinite. In these cases `Nil` is returned.
     
     - parameter number: An `NSNumber` value.
     
     - returns: An initialized enum or `Nil` if the number did not meet requirements.
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
