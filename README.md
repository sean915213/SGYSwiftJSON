# sgy-swift-json
An iOS Swift JSON serialization and deserialization library.

## Summary
The SGYSwiftJSON library is a **Swift-only** (due to extensive use of Mirror) library that converts typed Swift classes to JSON, and visa versa. Conversions are primarily done using extensive use of protocols to expose the contained types within Swift's classes. Therefore, **Swift's generic types are automatically implemented** It is also **not necessary to inherit from NSObject in-order to be deserializable**.  It's extremely convenient to do so, though.  Current limitations of the library:
### Serialization
* **Structs** - Structs are not inherently supported as they cannot be converted to AnyObject.  A protocol is provided (*SGYJSONProxyConvertible*) that a struct can adhere to in order to provide an alternative object.
* **Dates** - Dates require that SGYJSONSerializer be provided with a block that returns AnyObject (*dateConversionBlock*).

### Deserialization
* **Creatable** - All objects/collections/dictionaries being applied from a deserialized value must adhere to SGYJSONCreatable.  Ie. must provide a parameterless initializer.  Extensions are provided which meet this requirement for the most commonly used collections and dictionaries, as well as an NSObject subclass provided for custom classes to adhere to.
* **Classes** - Any custom class meant to be deserialized from a JSON dictionary must provide a function to set values via keys.  A subclass of NSObject is already provided which adheres to this (and the above) requirement (* SGYDeserializableNSObject*).
* **Collections** - Any collection meant to be deserialized from a JSON collection must expose a method which allows appending an array of [AnyObject]. Extensions are included covering common collections.
* **Dictionaries** - Any dictionary meant to be deserialized from a JSON dictionary must expose a method which allows merging a dictionary of [String: AnyObject]. Extensions are inluced covering common dictionaries.
* **Dates** - A conversion block must be supplied in-order to convert AnyObject to NSDate.
