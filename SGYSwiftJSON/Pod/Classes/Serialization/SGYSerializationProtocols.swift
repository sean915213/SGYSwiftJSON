//
//  SGYSerializationProtocols.swift
//  SGYSwiftJSON
//
//  Created by Sean Young on 9/25/15.
//  Copyright © 2015 Sean Young. All rights reserved.
//

import Foundation

/**
*  A protocol any struct may adhere to in-order to provide a valid JSON representation.
*/
public protocol SGYJSONProxyConvertible {
    var jsonProxy: AnyObject { get }
}

/**
*  A protocol any value may adhere to in-order to provide a string for JSON representation.
*/
public protocol SGYJSONStringConvertible {
    var jsonString: String { get }
}

/**
*  A protocol any value may adhere to in-order to provide a number for JSON representation.
*/
public protocol SGYJSONNumberConvertible {
    var jsonNumber: NSNumber { get }
}



public protocol JSONLeafRepresentable {
    var jsonLeafValue: JSONLeafValue? { get }
}