//
//  SGYSwiftProtocols.swift
//  SGYSwiftConverterTest
//
//  Created by Sean Young on 8/23/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import Foundation

extension RangeReplaceableCollectionType where Self: SGYCollectionCreatable {
    mutating func appendContentsOf(array: [AnyObject]) {
        array.forEach { if let e = $0 as? Generator.Element { append(e) } }
    }
}

extension Dictionary: SGYDictionaryCreatable {
    mutating func mergeContentsOf(dictionary: [String: AnyObject]) {
        dictionary.forEach {
            if let k = $0 as? Key, v = $1 as? Value { self[k] = v }
        }
    }
}

// Simple declarations that these types adhere, allowing extension on protocol to do the work

extension Array: SGYCollectionCreatable { }

extension Set: SGYCollectionCreatable {
    mutating func appendContentsOf(array: [AnyObject]) {
        array.forEach { if let e = $0 as? Element { insert(e) } }
    }
}



