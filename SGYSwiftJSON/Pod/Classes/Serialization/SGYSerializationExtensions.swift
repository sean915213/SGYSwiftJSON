//
//  SGYSerializationExtensions.swift
//  SGYSwiftJSON
//
//  Created by Sean Young on 9/25/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import Foundation

// MARK: - Number Conversion

extension NSNumber: SGYJSONNumberConvertible {
    public var jsonNumber: NSNumber { return self }
}

extension Double: SGYJSONNumberConvertible {
    public var jsonNumber: NSNumber { return self }
}

extension Int: SGYJSONNumberConvertible {
    public var jsonNumber: NSNumber { return self }
}

// --------

extension NSNumber: JSONLeafRepresentable {
    public var jsonLeafValue: JSONLeafValue? { return JSONLeafValue(self) }
}

extension Double: JSONLeafRepresentable {
    public var jsonLeafValue: JSONLeafValue? { return JSONLeafValue(self) }
}

extension Int: JSONLeafRepresentable {
    public var jsonLeafValue: JSONLeafValue? { return JSONLeafValue(self) }
}


// MARK: - String Conversion

extension String: SGYJSONStringConvertible {
    public var jsonString: String { return self }
}

extension NSString: SGYJSONStringConvertible {
    public var jsonString: String { return self as String }
}

extension SGYJSONNumberConvertible where Self: SGYJSONStringConvertible  {
    public var jsonString: String { return jsonNumber.description }
}

extension NSNumber: SGYJSONStringConvertible { }
extension Double: SGYJSONStringConvertible { }
extension Int: SGYJSONStringConvertible { }

// --------

extension String: JSONLeafRepresentable {
    public var jsonLeafValue: JSONLeafValue? { return JSONLeafValue(self) }
}

extension NSString: JSONLeafRepresentable {
    public var jsonLeafValue: JSONLeafValue? { return JSONLeafValue(self) }
}

// MARK: - NSNull Conversion

extension NSNull: JSONLeafRepresentable {
    public var jsonLeafValue: JSONLeafValue? { return JSONLeafValue(self) }
}




