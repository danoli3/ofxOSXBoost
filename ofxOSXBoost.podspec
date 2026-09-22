Pod::Spec.new do |s|
  s.name                        = "ofxOSXBoost"
  s.version                     = "1.92.0"
  s.summary                     = "Boost C++ libraries precompiled for macOS"
  s.description                 = <<-DESC
Boost C++ libraries packaged as a static XCFramework for macOS (x86_64 + arm64)
using the macOS 10.15+ deployment target.  The package contains the complete
Boost header tree and a documented selection of compiled Boost libraries.
                             DESC
  s.homepage                    = "https://github.com/danoli3/ofxOSXBoost"
  s.documentation_url           = "https://github.com/danoli3/ofxOSXBoost/releases/tag/1.92.0"
  s.license                     = { :type => "BSL-1.0", :file => "LICENSE.md" }
  s.author                      = { "Danoli3" => "danoli3@gmail.com" }

  s.platform                    = :osx, "10.15"
  s.osx.deployment_target       = "10.15"
  s.cocoapods_version           = ">= 1.9"
  s.requires_arc                = false
  s.source                      = {
         :git => "https://github.com/danoli3/ofxOSXBoost.git", :tag => "#{s.version}" }

  s.vendored_frameworks         = "libs/boost/osx/boost.xcframework"
  s.libraries                   = "c++"
  s.module_map                  = false
  s.preserve_paths              = "BUILD-INFO.txt",
                                  "libs/boost/cmake/**/*",
                                  "libs/boost/pkgconfig/**/*"

end
