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






