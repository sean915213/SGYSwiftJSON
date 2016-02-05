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
    public var jsonLeafValue: JSONLeafValue? { return JSONLeafValue(self) }
}

extension Double: JSONLeafRepresentable {
    public var jsonLeafValue: JSONLeafValue? { return JSONLeafValue(self) }
}

extension Int: JSONLeafRepresentable {
    public var jsonLeafValue: JSONLeafValue? { return JSONLeafValue(self) }
}


// MARK: - String Conversion

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




