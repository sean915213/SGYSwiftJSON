# SGYSwiftJSON

[![CI Status](http://img.shields.io/travis/Sean G. Young/SGYSwiftJSON.svg?style=flat)](https://travis-ci.org/Sean G. Young/SGYSwiftJSON)
[![Version](https://img.shields.io/cocoapods/v/SGYSwiftJSON.svg?style=flat)](http://cocoapods.org/pods/SGYSwiftJSON)
[![License](https://img.shields.io/cocoapods/l/SGYSwiftJSON.svg?style=flat)](http://cocoapods.org/pods/SGYSwiftJSON)
[![Platform](https://img.shields.io/cocoapods/p/SGYSwiftJSON.svg?style=flat)](http://cocoapods.org/pods/SGYSwiftJSON)

A library seeking to provide an automatic and type-safe approach to converting Swift types to and from JSON.

- [Summary](#summary)
- [Quick Start](#quick-start)
- [Serialization](#serialization)
- [Deserialization](#deserialization)
- [Examples](#examples)
 - [Basic](#examples-basic)
 - [Swifty](#examples-swifty)
 - [Swiftier](#examples-swiftier)
 - [Date](#examples-date)

<a name="summary"></a>
## Summary
SGYSwiftJSON is a library that seeks to dramatically simplify serialization and deserialization of **Swift only** models. The primary goal of this library is to eliminate the majority of the code required to convert arbitrary objects into JSON and vice versa. This includes recursive conversion of types contained in collections, dictionaries, and complex objects. Out-of-the-box functionality includes support for the majority of common Foundation types and a ready to inherit base class for complex types (*not required, but easier*).  Protocols are provided which allow extending functionality to unusual objects.

<a name="quick-start"></a>
## Quick Start
The majority of models written with JSON serialization in mind are already supported.  Any object graph that conforms to the following should work out-of-the-box:
* All collections are the  `Array`, `Set`, `NSArray`, or `NSMutableArray` types with an element type that adheres to this collection of rules.
* All dictionaries have a `String` or `NSString` key type and a value type which adheres to this collection of rules.
* All complex types conform to `JSONKeyValueCreatable`.  This is most easily achieved by using `JSONCreatableObject` as the base class.
* All numeric types are `NSNumber`, `NSDecimalNumber` or can be bridged to `NSNumber` and are not declared optional.

If you do not wish to have to adhere to the above limitations then it is possible to extend most other types using the defined protocols. Details on these protocols and how they're evaluated during serialization and deserialization can be found below.

*Note: Several of the above limitations do not apply or are much more lenient if you do not wish to implement deserialization.*

<a name="serialization"></a>
### Serialization
Serialization is supported via protocols and the use of Swift's `Mirror`. Any object passed to be serialized is checked for the following conditions:
 1. Conforms to `JSONProxyProvider` - The `jsonProxy` property of the object will be retrieved and passed through this same logic tree.
 2. Conforms to `JSONLeafRepresentable` - Objects adhering to this protocol can be represented as a JSON leaf object.  I.e `NSString`, `NSNumber`, or `NSNull`.  Beyond the 3 leaf values accepted the structs `String`, `Bool`, `Int`, `Float`, and `Double` conform to this protocol.
 3. Is a `Date` -  If the object is an `Date` and does not conform to any of the above protocols then the *dateConversionBlock*, if provided, is used to convert to `JSONLeafValue` or the property is skipped if no block exists.
 4. Conforms to `SGYDictionaryReflection` - The object will be converted to a dictionary of strings keys and object values. The generic `Dictionary` and `NSDictionary` both adhere to this protocol.
 5. Conforms to `SGYCollectionReflection` - The object's contained elements will be converted and put into an array. `Array`, `NSArray`, and `Set` adhere to this protocol.
 6. None of the above - The object's property's and values will be enumerated using `Mirror` and converted to a dictionary.

<a name="deserialization"></a>
### Deserialization
Deserialization is considerably more difficult than serialization as it requires all types have a parameterless initializer, can assign arbitrary values, and are able to report the types they contain.  Upon deserialization of an `NSArray` or `NSDictionary` (the only objects produced by `JSONSerialization`) the following logic is performed:
 1. The type arguments are determined by the protocol that the object being deserialized into conforms:
  *  If the object conforms to `JSONKeyValueCreatable` the object's properties and type values are determined using `Mirror`.  The object produced by `JSONSerialization` must be an `NSDictionary`or an error is thrown.
  *  If the object conforms to `JSONDictionaryCreatable` the object's key and value type are retrieved using the protocol's *keyValueTypes* property. The object produced by `JSONSerialization` must be an `NSDictionary`or an error is thrown.
  *  If the object conforms to `JSONCollectionCreatable` the object's element type is retrieved using the protocol's *elementType* property. The object produced by `JSONSerialization` must be an `NSArray`or an error is thrown.
 2. If the value to be deserialized into is an array then all values will be converted to the array's containing `Element` type.  Similarly, dictionaries have the containing values converted to their `Value` type.  For complex objects the value is converted using its `Mirror` property representation.  This conversion is done using the following logic:
  1. If the declared type is `Any`, `AnyObject` or the declared type matches the deserialized type then the deserialized type is assigned directly.
  2. If the declared type is `Date` then the `dateConversionBlock` is used to convert the deserialized `Any` value to `Date`.  If the block is not declared or returns nil the property is not assigned.
  2. If the deserialized value is a leaf value then the deserialized type must conform to `JSONLeafConvertable` and will be constructed using the leaf value and assigned.  Otherwise the deserialized value is not assigned.
  3. If the deserialized value is the `[Any]` type and the declared type is `JSONCollectionCreatable` an array will be initialized and returned using the array conversion logic.  Otherwise the deserialized value is not assigned.
  4. If the deserialized value is the `[String: Any]` type and the declared type is `JSONDictionaryCreatable` an array will be initialized and returned using the dictionary conversion logic.  Otherwise the deserialized value is not assigned.

<a name="examples"></a>
## Examples
All the examples will expand upon an arbitrary `Person` class. We'll begin with a very basic class and modify/expand it to utilize more complicated/Swifty properties.

<a name="examples-basic"></a>
### Basic Example
Let's begin with a model that requires nothing to convert:
```swift
class Person {
    var name: String?
    var birthdate: String?
    var favoriteColor: String?
    var bestFriends: [Person]?
    var categorizedFriends: [String: Person]?
    var followersCount: NSNumber?
}
```
Serialization is simple. Assume `someGuy` is an instance of `Person` with arbitrary values:
```swift
let serializer = SGYJSONSerializer()
do {
    let jsonData = try serializer.serialize(someGuy)
} catch let error as NSError {
    // Optionally catch specific errors
}
```
Deserialization requires one simple change.  We need a way to assign properties to the class.  The easiest way to do this is inheriting from `JSONCreatableObject` which implements `JSONKeyValueCreatable` via `NSObject`'s key value coding:
```swift
class Person: JSONCreatableObject
```
Then deserialize:
```swift
let deserializer = SGYJSONDeserializer()
do {
    let jsonGuy: Person = try deserializer.deserialize(jsonData)
} catch let error as NSError {
    // Optionally catch specific errors
}
```
<a name="examples-swifty"></a>
### More Swifty Example
The above example is already way less effort than normal conversion. But we're still using that ObjC object `NSNumber` and that's annoying to unwrap.  Luckily for serialization the automatic Swift bridging does our work for us.  We can simply redefine `followersCount` to: 
```swift
    var followersCount: Int?
```
This will serialize fine.  But deserialization is a problem.  The property `followersCount` will be properly converted to an `Int`. But `JSONCreatableObject` uses key value coding so attempting to assign to `Int?` will throw an error. The solution is simple:
```swift
    var followersCount: Int = 0 // No reason to be nil anyway.  If value doesn't exist 0 is reasonable.
```
This will deserialize just fine.   If you're hell bent on using optional Foundation types then see the next section's info on overriding `setValue:forProperty`.
<a name="examples-swiftier"></a>
### Even Swiftier Example
Now the model looks a bit closer to something we might actually design without de/serialization in mind.  But what about the `favoriteColor` property? That absolutely begs to be a Swift enum.  Serialization is, again, simpler to perform.  We define `Color` enum that conforms to a compound protocol:
```swift
enum Color: String, JSONLeafEnum {
    case red = "Red", green = "Green", blue = "Blue", yellow = "Yellow"
}
```
Now modify the type on `Person`:
```swift
    var favoriteColor: Color?
```
This will serialize just fine and produce the associated `rawValue` as the JSON value.  Deserialization is more difficult for the same reasons as `Int`.  Except Swift enums cannot be assigned via KVC at all.  The only option is to override `setValue:property:`:
```
    override func setValue(value: Any, property: String) throws {
        if property == "color" { color = value as? Color }
        else { try super.setValue(value, property: property) }
    }
```
Now the `Person` class will deserialize the JSON value into an optional Swift enum.
<a name="examples-date"></a>
### Dates
Strictly a date is not a JSON value. But its use, and therefore need to convert, is constant.  Because there are so many ways to represent a date value the serializer and deserializer classes expose a `dateConversionBlock` property for the explicit purpose of conversion.
First let's convert `birthdate` to a `Date` type:
```swift
    var birthdate: Date?
```
Since most JSON representations of a date are string or number types the date conversion block on `SGYJSONSerializer` is expected to return a `JSONLeafValue` enum.  Let's assume whatever consumes our JSON expects dates in `DateFormatter`'s `MediumStyle`.  Then the only addition to our serialization from before is the assignment of this block:
```swift
let formatter = DateFormatter()
formatter.dateStyle = .MediumStyle
serializer.dateConversionBlock = { (date) in formatter.stringFromDate(date) }
// Continue serialization as before
```
Deserialization is similar.  The main difference is the `dateConversionBlock` on the deserializer accepts a more general argument of `Any` in order to allow conversion to `Date` from any arbitrarily deserialized value:
```swift
let formatter = DateFormatter()
formatter.dateStyle = .mediumStyle
deserializer.dateConversionBlock = { (jsonValue) -> Date? in
    guard let value = jsonValue as? String else { return nil }
    return formatter.dateFromString(value)
}
// Continue deserialization as before
```


