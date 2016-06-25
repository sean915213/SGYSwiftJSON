# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).
This change log adheres to the suggested [keep-a-change-log](https://github.com/olivierlacan/keep-a-changelog) standards.

## [1.1.3]
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

[1.1.3]: https://github.com/sean915213/SGYSwiftJSON/compare/1.1.2...1.1.3
[1.1.2]: https://github.com/sean915213/SGYSwiftJSON/compare/1.1.1...1.1.2
[1.1.1]: https://github.com/sean915213/SGYSwiftJSON/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/sean915213/SGYSwiftJSON/compare/1.0.1...1.1.0
[1.0.1]: https://github.com/sean915213/SGYSwiftJSON/compare/1.0.0...1.0.1
