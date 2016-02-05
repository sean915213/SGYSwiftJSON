//
//  ReflectionExtensions.swift
//  SGYSwiftJSON
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

// MARK: - Collection Extensions

// Extending SequenceType requires this to auto-implement the property.  Cannot do simple extension on SequenceType.
extension SequenceType where Self: SGYCollectionReflection {
    // Auto-implementation of protocol for all SequenceTypes
    public static var elementType: Any.Type { return Generator.Element.self }
}

extension NSArray: SGYCollectionReflection { }

extension Array: SGYCollectionReflection { }

extension Set: SGYCollectionReflection { }

// MARK: - Dictionary Extensions

extension Dictionary: SGYDictionaryReflection {
    public static var keyValueTypes: (key: Any.Type, value: Any.Type) { return (key: Key.self, value: Value.self) }
}

extension NSDictionary: SGYDictionaryReflection  {
    public static var keyValueTypes: (key: Any.Type, value: Any.Type) { return (key: Key.self, value: Value.self) }
}

