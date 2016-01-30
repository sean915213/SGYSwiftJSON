//
//  SGYDeserializationExtensions.swift
//  SGYSwiftJSON
//
//  Created by Sean Young on 8/23/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import Foundation

extension RangeReplaceableCollectionType where Self: SGYCollectionCreatable {
    public mutating func appendContentsOf(array: [AnyObject]) {
        array.forEach { if let e = $0 as? Generator.Element { append(e) } }
    }
}

extension Dictionary: SGYDictionaryCreatable {
    public mutating func mergeContentsOf(dictionary: [String: AnyObject]) {
        dictionary.forEach {
            if let k = $0 as? Key, v = $1 as? Value { self[k] = v }
        }
    }
}

// Simple declarations that these types adhere, allowing extension on protocol to do the work

extension Array: SGYCollectionCreatable { }

extension Set: SGYCollectionCreatable {
    public mutating func appendContentsOf(array: [AnyObject]) {
        array.forEach { if let e = $0 as? Element { insert(e) } }
    }
}


extension String: JSONLeafCreatable {
    public init?(jsonValue: JSONLeafValue) {
        switch jsonValue {
        case .String(let string as String): self = string
        case .Number(let number): self = "\(number)"
        default: return nil
        }
    }
}

extension Double: JSONLeafCreatable {
    public init?(jsonValue: JSONLeafValue) {
        switch jsonValue {
        case .String(let string as String):
            guard let double = Double(string) else { return nil }
            self = double
        case .Number(let number):
            self = number.doubleValue
        default:
            return nil
        }
    }
}

extension Int: JSONLeafCreatable {
    public init?(jsonValue: JSONLeafValue) {
        switch jsonValue {
        case .String(let string as String):
            guard let int = Int(string) else { return nil }
            self = int
        case .Number(let number):
            self = number.integerValue
        default:
            return nil
        }
    }
}



