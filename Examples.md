## Examples
All the examples will expand upon an arbitrary `Person` class. We'll begin with a very basic class and modify/expand it to utilize more complicated/Swifty properties.

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
### More Swifty Example
The above example is already way less effort than normal conversion. But we're still using that ObjC object `NSNumber` and that's annoying to unwrap.  Luckily for serialization the automatic Swift bridging does our work for us.  We can simply redefine `followersCount` to: 
```swift
    var followersCount: Int?
```
This will serialize fine.  But deserialization is a problem.  The property `followersCount` will be properly converted to an `Int`. But `JSONCreatableObject` uses key value coding so attempting to assign to `Int?` will throw an error. The solution is simple:
```swift
    var followersCount: Int = -1 // Sentinal value indicates it was never changed- ie nil
```
This will deserialize just fine.   If you're hell bent on using optional foundation types then see the section on enums for overriding `setValue:forProperty`.
### Even Swiftier Example
Now the model looks a bit closer to something we might actually design without de/serialization in mind.  But what about the `favoriteColor` property? That absolutely begs to be a Swift enum.  Serialization is, again, simpler to perform.  We define `Color` enum that conforms to a number of protocols that do the work:
```swift
enum Color: String, JSONLeafEnum, JSONLeafRepresentable, JSONLeafCreatable {
    case Red = "Red", Green = "Green", Blue = "Blue", Yellow = "Yellow"
}
```
Now modify the type on `Person`:
```swift
    var favoriteColor: Color?
```
This will serialize just fine and produce the associated `rawValue` as the JSON value.  Deserialization is more difficult for the same reasons as `Int`.  Except Swift enums cannot be assigned via KVC at all.  The only option is to override `setValue:property`:
```
    override func setValue(value: Any, property: String) throws {
        if property == "color" { color = value as? Color }
        else { try super.setValue(value, property: property) }
    }
```
Now the `Person` class will deserialize the JSON value into an optional Swift enum.
### Dates
Strictly date is not a JSON value. But its use, and therefore need to convert, is constant.

*In Progress*
