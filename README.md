# SGYSwiftJSON
An iOS Swift JSON serialization and deserialization library.

## Summary
The SGYSwiftJSON library is a library that dramatically simplifies serialization and deserialization of **Swift only** models. The primary goal of this library is to eliminate the majority of the code required to convert arbitrary objects into JSON and vice versa. Out-of-the-box functionality supports conversion of most common objects, collections, and dictionaries.  Protocols are provided which allow extending functionality to unusual objects.

### Serialization
Serialization is supported via protocols and the use of Swift's `Mirror`. Any object passed to be deserialized is checked for the following conditions:
 1. Conforms to `JSONProxyProvider` - The *jsonProxy* property of the object will be retrieved and passed through this same logic tree.
 2. Conforms to `JSONLeafRepresentable` - Objects adhering to this protocol can be represented as a JSON leaf object.  I.e `NSString`, `NSNumber`, or `NSNull`.  Beyond the 3 leaf values accepted the structs `String`, `Double`, and `Int` conform to this protocol.
 3. Is an `NSDate` -  If the object is an `NSDate` and does not conform to any of the above protocols then the *dateConversionBlock*, if provided, is used to convert to `JSONLeafRepresentable` or the property is skipped if no block exists.
 4. Conforms to `SGYDictionaryReflection` - The object will be converted to a dictionary of strings keys and object values. The genneric `Dictionary` and `NSDictionary` both adhere to this protocol.
 5. Conforms to `SGYCollectionReflection` - The object's contained elements will be converted and put into an array. `Array`, `NSArray`, and `Set` adhere to this protocol.
 6. None of the above - The object's property's and values will be enumerated using `Mirror` and converted to a dictionary.
 
#### Common Serialization Problems
* `Enum` - Enumerations are most appropriately handled by having the enumeration conform to `JSONLeafRepresentable` and return the `JSONLeafValue` struct initialized with their string or number *rawValue*.
* `NSDate` - There are 2 strategies for handling `NSDate` based on the project:
 * If all dates are represented using the same format then extend `NSDate` to conform to `JSONLeafRepresentable` and construct `JSONLeafValue` using the specific string or numeric representation.
 * If dates using different formatting for different situations then instead initialize a separate `SGYJSONSerializer` instance for each format and assign an appropriate *dateConversionBlock*.

### Deserialization
Deserialization is considerably more difficult than serialization as it requires all types have a parameterless initializer, can assign arbitrary values, and are able to report the types they contain.  Upon deserialization of an `NSArray` or `NSDictionary` (the only objects produced by `NSJSONSerialization`) the following logic is performed:
 1. The type arguments are determined by the protocol that the object being deserialized into conforms:
  *  If the object conforms to `SGYKeyValueCreatable` the object's properties and type values are determined using `Mirror`.  The object produced by `NSJSONSerialization` must be an `NSDictionary`or an error is thrown.
  *  If the object conforms to `SGYDictionaryCreatable` the object's key and value type are retrieved using the protocol's *keyValueTypes* property. The object produced by `NSJSONSerialization` must be an `NSDictionary`or an error is thrown.
  *  If the object conforms to `SGYCollectionCreatable` the object's element type is retrieved using the protocol's *elementType* property. The object produced by `NSJSONSerialization` must be an `NSArray`or an error is thrown.
 2. Once the type to deserialize the values into is determined several chec


* **Creatable** - All objects/collections/dictionaries being applied from a deserialized value must adhere to SGYJSONCreatable.  Ie. must provide a parameterless initializer.  Extensions are provided which meet this requirement for the most commonly used collections and dictionaries, as well as an NSObject subclass provided for custom classes to adhere to.
* **Classes** - Any custom class meant to be deserialized from a JSON dictionary must provide a function to set values via keys.  A subclass of NSObject is already provided which adheres to this (and the above) requirement (* SGYDeserializableNSObject*).
* **Collections** - Any collection meant to be deserialized from a JSON collection must expose a method which allows appending an array of [AnyObject]. Extensions are included covering common collections.
* **Dictionaries** - Any dictionary meant to be deserialized from a JSON dictionary must expose a method which allows merging a dictionary of [String: AnyObject]. Extensions are inluced covering common dictionaries.
* **Dates** - A conversion block must be supplied in-order to convert AnyObject to NSDate.
