# SGYKVCSafeNSObject
### This library provides an extension on NSObject that allows the use of key value coding without fear of exceptions.

#### Overview
Key value coding is a bit of Cocoa magic that remains unique to ObjC through `NSObject`.  However, NSObject's KVO methods throw exceptions when things go south and *these cannot be caught in Swift*.  The category this library provides wraps NSObject's KVO methods in @try/@catch blocks and when an exception is thrown an `NSError` object is populated instead.

#### Usage
Usage is simple.  First import:

````swift
import SGYKVCSafeNSObject
````

Then use key value coding as before by optionally passing `NSError`:

```swift
let object = NSObject()
var error: NSError?
object.setValue("any value", forKey: "not a key", error:&error)
if let error = error { NSLog("Key value assignment error: \(error.localizedDescription).") }
```

#### Known Issues
* When using *valueForKey:* or *valueForKeyPath:* the exception is not returned in a userInfo dictionary.  During testing attempting to pass the caught `NSException` in these methods seems to randomly cause an EXC_BAD_ACCESS.  So to maintain safety the exception object is not packed into a userInfo dictionary until I can nail down the reason.
