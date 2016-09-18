//
//  EnumImplementation.swift
//  SGYSwiftJSON
//
//  Created by Sean G Young on 2/11/16.
//
//

import Foundation

public typealias JSONLeafEnum = JSONLeafCreatable & JSONLeafRepresentable

extension RawRepresentable where Self: JSONLeafCreatable, Self.RawValue: JSONLeafCreatable {
    /**
     Attempts initializing the associated `JSONLeafEnum` type.
     
     - parameter jsonValue: A JSON leaf value.
     
     - returns: An initialized enum type or `nil` if it could not be constructed from `jsonValue`.
     */
    public init?(jsonValue: JSONLeafValue) {
        guard let leafValue = RawValue(jsonValue: jsonValue) else { return nil }
        self.init(rawValue: leafValue)
    }
}

extension RawRepresentable where Self: JSONLeafRepresentable, Self.RawValue: JSONLeafRepresentable {
    /// Returns `rawValue`'s leaf value representation.
    public var jsonLeafValue: JSONLeafValue? { return rawValue.jsonLeafValue }
}
