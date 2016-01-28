//
//  JSONLeafValue.swift
//  Pods
//
//  Created by Sean G Young on 1/28/16.
//
//

import Foundation

public struct JSONLeafValue {
    
    // MARK: - Initialization
    
    public init(_ string: NSString) { value = string }
    public init(_ null: NSNull) { value = null }
    
    public init?(_ number: NSNumber) {
        // Per documentation NSJSONSerialization will fail on NaN and infinite numbers
        guard !number.doubleValue.isNaN && !number.doubleValue.isInfinite else { return nil }
        value = number
    }
    
    // MARK: - Properties
    
    let value: AnyObject
}
