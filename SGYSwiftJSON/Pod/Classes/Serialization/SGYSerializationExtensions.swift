//
//  SGYSerializationExtensions.swift
//  SGYSwiftConverterTest
//
//  Created by Sean Young on 9/25/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import Foundation

// MARK: - Number Conversion

extension NSNumber: SGYJSONNumberConvertible {
    var jsonNumber: NSNumber { return self }
}

extension Double: SGYJSONNumberConvertible {
    var jsonNumber: NSNumber { return self }
}

extension Int: SGYJSONNumberConvertible {
    var jsonNumber: NSNumber { return self }
}

// MARK: - String Conversion

extension String: SGYJSONStringConvertible {
    var jsonString: String { return self }
}

extension NSString: SGYJSONStringConvertible {
    var jsonString: String { return self as String }
}

extension SGYJSONNumberConvertible where Self: SGYJSONStringConvertible  {
    var jsonString: String { return jsonNumber.description }
}

extension NSNumber: SGYJSONStringConvertible { }
extension Double: SGYJSONStringConvertible { }
extension Int: SGYJSONStringConvertible { }






