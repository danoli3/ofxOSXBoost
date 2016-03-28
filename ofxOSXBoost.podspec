Pod::Spec.new do |s|
  s.name         = "ofxOSXBoost"
  s.version      = "1.60.0"
  s.summary      = "Boost C++ library"
  s.description  = <<-DESC
Boost is the library that can (and should) be used to ease c++ development.
                   DESC
  s.homepage     = "http://www.boost.org"
  s.license      = 'Boost'
  s.author       = { "Danoli3" => "danoli3@gmail.com" }
  s.source       = { :git => "https://github.com/danoli3/ofxOSXBoost.git", :tag => "#{s.version}" }

  s.platform     = :osx, '10.9'
  s.osx.deployment_target = '10.9'
  s.requires_arc = false
  s.osx.source_files = "libs/boost/include/**/*.{h,hpp,ipp}"
  s.osx.header_mappings_dir = "libs/boost/include"
  s.osx.public_header_files = "libs/boost/include/**/*.{h,hpp,ipp}"

  s.osx.preserve_paths = "libs/boost/include/**/*.{h,hpp,ipp}", "libs/boost/osx/**/*.a"
  s.osx.vendored_libraries = "libs/boost/osx/**/*.a"

end
