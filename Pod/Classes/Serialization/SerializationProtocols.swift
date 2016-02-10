//
//  SGYSerializationProtocols.swift
//  SGYSwiftJSON
//
//  Created by Sean Young on 9/25/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import Foundation

/**
*  A protocol any type may adhere to in-order to provide a valid JSON representation.
*/
public protocol JSONProxyProvider {
    /// Another value that should be convertible to JSON in some manner.
    var jsonProxy: Any { get }
}

/**
 *  A protocol any type may adhere to in-order to provide a valid JSON leaf value representation.
 */
public protocol JSONLeafRepresentable {
    /// A `JSONLeafValue` case that represent the type or `nil` if none exist.
    var jsonLeafValue: JSONLeafValue? { get }
}