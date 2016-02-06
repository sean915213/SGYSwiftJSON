#
# Be sure to run `pod lib lint SGYSwiftJSON.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SGYSwiftJSON"
  s.version          = "0.1.4"
  s.summary          = "A library seeking to provide an automatic and type-safe approach to converting Swift models to and from JSON."

# This description is used to generate tags and improve search results.
  s.description      = "SGYSwiftJSON seeks to dramatically simplify serialization and deserialization of Swift model to and from JSON. While serialization is fully supported, the primary goal is to go beyond simple key-value coding to provide a system for creating properly typed object graphs from JSON. This includes recursive conversion of types contained in collections, dictionaries, and complex objects. Out-of-the-box functionality includes support for the majority of common Foundation types and a ready to inherit base class for complex types (not required, but easier). Protocols are provided which allow extending functionality to unusual objects."
  s.homepage         = "https://github.com/sean915213/SGYSwiftJSON"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Sean G Young" => "sean.g.young@gmail.com" }
  s.source           = { :git => "https://github.com/sean915213/SGYSwiftJSON.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  # s.resource_bundles = {
  #     'SGYSwiftJSON' => ['Pod/Assets/*.png']
  #   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SGYKVCSafeNSObject', '~> 1.0'
end
