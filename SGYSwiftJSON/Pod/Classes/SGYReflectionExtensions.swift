//
//  SGYReflectionExtensions.swift
//  SGYSwiftConverterTest
//
//  Created by Sean Young on 9/27/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import Foundation

extension Optional: SGYOptionalReflection {
    static var wrappedType: Any.Type { return Wrapped.self }
    
    var wrappedValue: Any? {
        switch self {
        case .Some(let value): return value
        default: return nil
        }
    }
}

// Extending SequenceType requires this to auto-implement the property.  Cannot do simple extension on SequenceType.
extension SequenceType where Self: SGYCollectionReflection {
    // Auto-implementation of protocol for all SequenceTypes
    static var elementType: Any.Type { return Generator.Element.self }
}

extension Dictionary: SGYDictionaryReflection {
    static var keyValueTypes: (key: Any.Type, value: Any.Type) { return (key: Key.self, value: Value.self) }
}

extension NSDictionary: SGYDictionaryReflection {
    static var keyValueTypes: (key: Any.Type, value: Any.Type) { return (key: Key.self, value: Value.self) }
}

extension NSArray: SGYCollectionReflection { }

extension Array: SGYCollectionReflection { }

extension Set: SGYCollectionReflection { }
