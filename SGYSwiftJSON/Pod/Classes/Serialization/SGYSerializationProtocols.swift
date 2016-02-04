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
    var jsonProxy: Any { get }
}

/**
 *  A protocol any type may adhere to in-order to provide a valid JSON leaf value representation.
 */
public protocol JSONLeafRepresentable {
    var jsonLeafValue: JSONLeafValue? { get }
}