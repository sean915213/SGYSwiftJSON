//
//  SGYSerializationExtensions.swift
//  SGYSwiftJSON
//
//  Created by Sean Young on 9/25/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import Foundation

// MARK: - Number Conversion

extension NSNumber: JSONLeafRepresentable {
    /// Provides a `JSONLeafValue.Number` case in order to conform to `JSONLeafRepresentable`.
    public var jsonLeafValue: JSONLeafValue? { return JSONLeafValue(self) }
}

extension Double: JSONLeafRepresentable {
    /// Provides a `JSONLeafValue.Number` case in order to conform to `JSONLeafRepresentable`.
    public var jsonLeafValue: JSONLeafValue? { return JSONLeafValue(self) }
}

extension Int: JSONLeafRepresentable {
    /// Provides a `JSONLeafValue.Number` case in order to conform to `JSONLeafRepresentable`.
    public var jsonLeafValue: JSONLeafValue? { return JSONLeafValue(self) }
}


// MARK: - String Conversion

extension String: JSONLeafRepresentable {
    /// Provides a `JSONLeafValue.String` case in order to conform to `JSONLeafRepresentable`.
    public var jsonLeafValue: JSONLeafValue? { return JSONLeafValue(self) }
}

extension NSString: JSONLeafRepresentable {
    /// Provides a `JSONLeafValue.String` case in order to conform to `JSONLeafRepresentable`.
    public var jsonLeafValue: JSONLeafValue? { return JSONLeafValue(self) }
}

// MARK: - NSNull Conversion

extension NSNull: JSONLeafRepresentable {
    /// Provides a `JSONLeafValue.Null` case in order to conform to `JSONLeafRepresentable`.
    public var jsonLeafValue: JSONLeafValue? { return JSONLeafValue(self) }
}




