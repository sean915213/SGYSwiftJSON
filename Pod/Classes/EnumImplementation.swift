//
//  EnumImplementation.swift
//  SGYSwiftJSON
//
//  Created by Sean G Young on 2/11/16.
//
//

import Foundation

/**
 *  Provides a protocol that 'leaf' enums can adhere to that automates JSON conversion.  The only requirement is that the enum's `RawValueType` adhere to `JSONLeafCreatable` and `JSONLeafRepresentable`. Among other commonly used types `String` and `Int` already meet this requirement.
 */
public protocol JSONLeafEnum {
    /// An associatedtype requirement that is automatically fulfilled by most 'leaf' enum types.
    associatedtype RawValueType: JSONLeafCreatable, JSONLeafRepresentable
    
    /**
     A failable initializer requirement that all enums, if meeting the `RawValueType` requirement, already implement.
     
     - parameter rawValue: The raw value.
     
     - returns: An initialized type or `nil`.
     */
    init?(rawValue: RawValueType)
    
    /// A property exposing this enum's raw value.
    var rawValue: RawValueType { get }
}

extension JSONLeafEnum where Self: JSONLeafCreatable {
    /**
     Attempts initializing the associated `JSONLeafEnum` type.
     
     - parameter jsonValue: A JSON leaf value.
     
     - returns: An initialized enum type or `nil` if it could not be constructed from `jsonValue`.
     */
    public init?(jsonValue: JSONLeafValue) {
        guard let leafValue = RawValueType(jsonValue: jsonValue) else { return nil }
        self.init(rawValue: leafValue)
    }
}

extension JSONLeafEnum where Self: JSONLeafRepresentable {
    /// Returns `rawValue`'s leaf value representation.
    public var jsonLeafValue: JSONLeafValue? { return rawValue.jsonLeafValue }
}
