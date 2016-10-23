//
//  ReflectionProtocols.swift
//  SGYSwiftJSON
//
//  Created by Sean Young on 9/27/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import Foundation

/**
*  Defined to allow unwrapping and assigning the contained type of a collection type.
*/
public protocol SGYCollectionReflection {
    /// This collection's `Element` or otherwise containing type.
    static var elementType: Any.Type { get }
}

/**
*  Defined to allow unwrapping and assigning the contained types of a generic dictionary.
*/
public protocol SGYDictionaryReflection {
    //associatedtype Key
    //associatedtype Value
    
    /// A tuple containing this dictionary's `Key` and `Value` types.
    static var keyValueTypes: (key: Any.Type, value: Any.Type) { get }
}

/**
 *  Defined to allow unwrapping an optional without knowing the wrapped type.
 */
protocol SGYOptionalReflection {
    static var wrappedType: Any.Type { get }
    
    var wrappedValue: Any? { get }
}
