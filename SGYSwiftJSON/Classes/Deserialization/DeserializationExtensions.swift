//
//  SGYDeserializationExtensions.swift
//  SGYSwiftJSON
//
//  Created by Sean Young on 8/23/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import Foundation

// MARK: JSONCollectionCreatable Conformance -

extension RangeReplaceableCollection where Self: JSONCollectionCreatable {
    /**
     Extends `RangeReplaceableCollectionType` types that implement `JSONCollectionCreatable`. Provides an automatic initializer that attempts casting the provided `AnyObject` collection to the type's `Generator.Element`.
     
     - parameter array: An array typed as `[AnyObject]` but intended to contain instances that can be cast to the type's `Generator.Element`.
     
     - returns: An initialized collection.
     */
    public init(array: [AnyObject]) {
        self.init()
        array.forEach { if let e = $0 as? Iterator.Element { append(e) } }
        
    }
}

extension Array: JSONCollectionCreatable { }

extension Set: JSONCollectionCreatable {
    /**
     An initializer that extends `Set` to conform to `JSONCollectionCreatable`.
     
     - parameter array: An array typed as `[AnyObject]` but intended to contain instances that can be cast to `Generator.Element`.
     
     - returns: An initialized set.
     */
    public init(array: [AnyObject]) {
        self.init()
        array.forEach { if let e = $0 as? Iterator.Element { insert(e) } }
        
    }
}


// MARK: JSONDictionaryCreatable Conformance -

extension Dictionary: JSONDictionaryCreatable {
    /**
     An initializer that extends `Dictionary` to conform to `JSONDictionaryCreatable`.
     
     - parameter dictionary: A dictionary typed as `[String: AnyObject]` but intended to contain values that can be cast to `Value`.
     
     - returns: An initialized dictionary.
     */
    public init(dictionary: [String: AnyObject]) {
        self.init()
        dictionary.forEach {
            if let k = $0 as? Key, let v = $1 as? Value { self[k] = v }
        }
    }
}

// MARK: JSONLeafCreatable Conformance -
// MARK: String

extension String: JSONLeafCreatable {
    /**
     Extends `String` to conform to `JSONLeafCreatable`. Fails only on the `Null` case.
     
     - parameter jsonValue: A `JSONLeafCreatable` enum case.
     
     - returns: An initialized `String` value or `nil`.
     */
    public init?(jsonValue: JSONLeafValue) {
        switch jsonValue {
        case .string(let string as String): self = string
        case .number(let number): self = "\(number)"
        default: return nil
        }
    }
}

// MARK: Numeric Structs

extension Int: JSONLeafCreatable {
    /**
     Extends `Int` to conform to `JSONLeafCreatable`. Fails conditionally on the `String` case and always on the `Null` case.
     
     - parameter jsonValue: A `JSONLeafCreatable` enum case.
     
     - returns: An initialized `Int` value or `nil`.
     */
    public init?(jsonValue: JSONLeafValue) {
        switch jsonValue {
        case .string(let string as String):
            guard let int = Int(string) else { return nil }
            self = int
        case .number(let number):
            self = number.intValue
        default:
            return nil
        }
    }
}

extension UInt: JSONLeafCreatable {
    /**
     Extends `UInt` to conform to `JSONLeafCreatable`. Fails conditionally on the `String` case and always on the `Null` case.
     
     - parameter jsonValue: A `JSONLeafCreatable` enum case.
     
     - returns: An initialized `UInt` value or `nil`.
     */
    public init?(jsonValue: JSONLeafValue) {
        switch jsonValue {
        case .string(let string as String):
            guard let uint = UInt(string) else { return nil }
            self = uint
        case .number(let number):
            self = number.uintValue
        default:
            return nil
        }
    }
}

extension Float: JSONLeafCreatable {
    /**
     Extends `Float` to conform to `JSONLeafCreatable`. Fails conditionally on the `String` case and always on the `Null` case.
     
     - parameter jsonValue: A `JSONLeafCreatable` enum case.
     
     - returns: An initialized `Float` value or `nil`.
     */
    public init?(jsonValue: JSONLeafValue) {
        switch jsonValue {
        case .string(let string as String):
            guard let float = Float(string) else { return nil }
            self = float
        case .number(let number):
            self = number.floatValue
        default:
            return nil
        }
    }
}

extension Double: JSONLeafCreatable {
    /**
     Extends `Double` to conform to `JSONLeafCreatable`. Fails conditionally on the `String` case and always on the `Null` case.
     
     - parameter jsonValue: A `JSONLeafCreatable` enum case.
     
     - returns: An initialized `Double` value or `nil`.
     */
    public init?(jsonValue: JSONLeafValue) {
        switch jsonValue {
        case .string(let string as String):
            guard let double = Double(string) else { return nil }
            self = double
        case .number(let number):
            self = number.doubleValue
        default:
            return nil
        }
    }
}

extension Bool: JSONLeafCreatable {
    /**
     Extends `Bool` to conform to `JSONLeafCreatable`. Fails conditionally on the `String` case and always on the `Null` case.
     
     - parameter jsonValue: A `JSONLeafCreatable` enum case.
     
     - returns: An initialized `Bool` value or `nil`.
     */
    public init?(jsonValue: JSONLeafValue) {
        switch jsonValue {
        case .string(let string):
            if let value = Bool(string as String) { self = value }
            return nil
        case .number(let number):
            self = Bool(number)
        case .null:
            return nil
        }
    }
}


