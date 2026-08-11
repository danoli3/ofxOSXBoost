class OfxOSXBoost < Formula
  desc "Boost C++ libraries precompiled for macOS"
  homepage "https://github.com/danoli3/ofxOSXBoost"
  url "https://github.com/danoli3/ofxOSXBoost/releases/download/1.61.0/ofxOSXBoost-1.61.0.tar.gz"
  sha256 "__SHA256_VALUE__"
  license "BSL-1.0"

  depends_on "cmake" => :build

  def install
    prefix.install Dir["ofxOSXBoost-*"]

          # Install XCFramework to /Library/Frameworks
    xcframework = Dir["ofxOSXBoost-1.61.0/libs/boost/osx/boost.xcframework"][0]
    framework_dir = "#{prefix}/Frameworks"
    mkdir_p framework_dir
    mv xcframework, "#{framework_dir}/boost.xcframework"
  end

  def test
    raise "XCFramework not installed" unless File.directory?("#{prefix}/Frameworks/boost.xcframework")
    raise "Info.plist missing" unless File.exist?("#{prefix}/Frameworks/boost.xcframework/Info.plist")
  end
end
