//
//  JSONLeafValue.swift
//  Pods
//
//  Created by Sean G Young on 1/28/16.
//
//

import Foundation

public enum JSONLeafValue {
    case String(NSString), Number(NSNumber), Null(NSNull)
    
    public init(_ string: NSString) { self = String(string) }
    
    public init(_ null: NSNull) { self = Null(null) }
    
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
