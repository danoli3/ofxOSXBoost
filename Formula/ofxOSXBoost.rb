class Ofxosxboost < Formula
  desc "Boost C++ libraries precompiled for macOS"
  homepage "https://github.com/danoli3/ofxOSXBoost"
  url "https://github.com/danoli3/ofxOSXBoost/releases/download/1.92.0/ofxOSXBoost-1.92.0.tar.gz"
  sha256 "__SHA256_VALUE__"
  license "BSL-1.0"

  def install
    libexec.install Dir["*"]
  end

  def test
    framework = libexec/"libs/boost/osx/boost.xcframework/macos-arm64_x86_64"
    (testpath/"smoke.cpp").write "#include <boost/version.hpp>\nint main(){return BOOST_VERSION == 109200 ? 0 : 1;}\n"
    system ENV.cxx, "-std=c++20", "-I#{framework}/Headers", testpath/"smoke.cpp",
           framework/"libboost.a", "-o", testpath/"smoke"
    system testpath/"smoke"
  end
end
