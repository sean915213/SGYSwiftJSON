//
//  JSONLeafValue.swift
//  Pods
//
//  Created by Sean G Young on 1/28/16.
//
//

import Foundation

/**
 *  A struct used to provide a valid JSON leaf value.
 */
public struct JSONLeafValue {
    
    // MARK: - Initialization
    
    /**
    Initializes `JSONLeafValue` with an `NSString`.
    
    - parameter string: An `NSString`.
    
    - returns: A constructed `JSONLeafValue`.
    */
    public init(_ string: NSString) { value = string }
    
    /**
     Initializes `JSONLeafValue` with an `NSNull` instance.
     
     - parameter string: An `NSNull` instance.
     
     - returns: A constructed `JSONLeafValue`.
     */
    public init(_ null: NSNull) { value = null }
    
    /**
     Initializes `JSONLeafValue` with an `NSNumber`.
     
     - parameter number: An `NSNumber`.  Initialization will return nil if this number is NaN or infinite.
     
     - returns: A constructed `JSONLeafValue` or nil if the `NSNumber` is NaN or infinite.
     */
    public init?(_ number: NSNumber) {
        // Per documentation NSJSONSerialization will fail on NaN and infinite numbers
        guard !number.doubleValue.isNaN && !number.doubleValue.isInfinite else { return nil }
        value = number
    }
    
    // MARK: - Properties
    
    let value: AnyObject
}
