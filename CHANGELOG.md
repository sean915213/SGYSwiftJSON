# Change Log
All notable changes to this project will be documented in this file.
This change log adheres to the suggested [keep-a-change-log](https://github.com/olivierlacan/keep-a-changelog) standards.

## [2.0.0]
#### Swift Refactoring
- Refactored entire code base for Swift 3.0.
- Rewrote several method signatures to adhere to new Swift API standards.
- Nested most enums per new API standards.

#### Code Changes
- Removed serializaton and deserialization protocols related to enums.  The related functionality now uses the `RawValueType` protocol to adhere to `JSONLeafCreatable` and `JSONLeafRepresentable`. The protocol `JSONLeafEnum` is now used to expose an enum type to serialization / deserialization.
- Removed the `unsupportedConversionBlock` property used to log deserialization problems.  All de/serialization methods now accept an optional `JSONWarningObserver` instance to log any non-fatal warnings during conversion.
- Due to the above change all de/serialization methods will no longer throw and terminate during a warning.

### Testing Changes
- Removed testing frameworks installed by Cocoapods and reverted to XCTest.

## [1.1.3]
#### Cocoapods 1.0 Update
- Updated Podfile to Cocoapods 1.0 syntax.
- Updated testing syntax.

## [1.1.2]
#### Code Bug Fix
- Fixed a bug when deserializing into a `JSONCreatableObject` that caused superclass properties to not be assigned.

#### Test Changes
- Added an inheritence hierarchy to the complex object tests.

## [1.1.1] - 2016-03-22
#### Minor Updates for Xcode 7.3.
- Fixed warnings introduced by Swift 2.2.
- Updated Nimble version to 3.2 in order to fix a new compiler error.

## [1.1.0] - 2016-02-12
#### Code Changes
- Added `JSONLeafEnum` protocol and associated extensions.

#### Test Changes
- Added a Swift enum property to complex object's serialization and deserialization tests.

#### Documentation Changes
- Code documentation additions and changes.
- README changes.

## [1.0.1] - 2016-02-09
#### Documentation Changes
- Made code documentation additions and changes.

## 1.0.0 - 2016-02-06
#### Initial Release
- Checked in and published initial tested version of library.

[2.0.0]: https://github.com/sean915213/SGYSwiftJSON/compare/1.1.3...2.0.0
[1.1.3]: https://github.com/sean915213/SGYSwiftJSON/compare/1.1.2...1.1.3
[1.1.2]: https://github.com/sean915213/SGYSwiftJSON/compare/1.1.1...1.1.2
[1.1.1]: https://github.com/sean915213/SGYSwiftJSON/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/sean915213/SGYSwiftJSON/compare/1.0.1...1.1.0
[1.0.1]: https://github.com/sean915213/SGYSwiftJSON/compare/1.0.0...1.0.1
