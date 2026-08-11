class OfxOSXBoost < Formula
  desc "Boost C++ libraries precompiled for macOS"
  homepage "https://github.com/danoli3/ofxOSXBoost"
  url "https://github.com/danoli3/ofxOSXBoost/releases/download/1.61.0/ofxOSXBoost-1.61.0.tar.gz"
  sha256 "__SHA256__"
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
"""

ADDON_PATH = f"{BASE}/addon_config.mk"
with open(ADDON_PATH, "w") as f: f.write(ADDON)
print(f"Updated {ADDON_PATH} ({os.path.getsize(ADDON_PATH)} bytes)")

# -- podspec --
PODSPEC = """Pod::Spec.new do |s|
  s.name                       = "ofxOSXBoost"
  s.version                    = "1.61.0"
  s.summary                    = "Boost C++ libraries precompiled for macOS"
  s.description                = <<-DESC
Boost C++ libraries packaged as a static XCFramework for macOS (x86_64 + arm64)
using the macOS 10.15+ deployment target.  The package contains the complete
Boost header tree and a documented selection of compiled Boost libraries.
                             DESC
  s.homepage                   = "https://github.com/danoli3/ofxOSXBoost"
  s.documentation_url          = "https://github.com/danoli3/ofxOSXBoost/releases/tag/1.61.0"
  s.license                    = { :type => "BSL-1.0", :file => "LICENSE.md" }
  s.author                     = { "Danoli3" => "danoli3@gmail.com" }

  s.platform                   = :osx, "10.15"
  s.osx.deployment_target      = "10.15"
  s.cocoapods_version          = ">= 1.9"
  s.requires_arc               = false
  s.source                     = {
         :git => "https://github.com/danoli3/ofxOSXBoost.git", :tag => "#{s.version}" }

  s.vendored_frameworks         = "libs/boost/osx/boost.xcframework"
  s.libraries                   = "c++"
  s.module_map                  = false
  s.preserve_paths              = "BUILD-INFO.txt",
                                 "libs/boost/cmake/**/*",
                                 "libs/boost/pkgconfig/**/*"

end
"""

PODSPEC_PATH = f"{BASE}/ofxOSXBoost.podspec"
with open(PODSPEC_PATH, "w") as f: f.write(PODSPEC)
print(f"Updated {PODSPEC_PATH} ({os.path.getsize(PODSPEC_PATH)} bytes)")

# -- .travis.yml --
TRAVIS = """language: objective-c
osx_image: xcode-14.3
matrix:
  include:
         - osx_image: xcode-14.3
           env: TYPE="libc++"
script:
         - scripts/build-$TYPE
git:
    depth: 10
"""

TRAVIS_PATH = f"{BASE}/.travis.yml"
with open(TRAVIS_PATH, "w") as f: f.write(TRAVIS)
print(f"Updated {TRAVIS_PATH}")

# -- .gitignore --
GITIGNORE = """# Compiled Object files
*.slo
*.lo
*.o

# *.a # We DO want this -- static libraries are the XCFramework payload

# Compiled Dynamic libraries
*.so
*.dylib

# Compiled Static libraries (keep .a from git, it is a placeholder)
*.lai
*.la

# Do not ignore the debug folder
!*/debug/
!*/debug/*

# XCFramework
*.xcframework/
*.xcframework.zip

# Xcode
build/
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
xcuserdata
*.xccheckout
*.moved-aside
DerivedData
*.xcuserstate

*.app

*.xcscheme

# Boost tarballs
*.bz2
*.gz
"""

GITIGNORE_PATH = f"{BASE}/.gitignore"
with open(GITIGNORE_PATH, "w") as f: f.write(GITIGNORE)
print(f"Updated {GITIGNORE_PATH}")

# -- Verify --
check = [ADDON_PATH, PODSPEC_PATH, TRAVIS_PATH, GITIGNORE_PATH, HOMEBREW_PATH]
for v in ["1.61.0", "1.62.0", "1.63.0", "1.64.0", "1.65.0", "1.66.0"]:
    check.append(f"{PACKAGING}/versions/{v}-components.tsv")

print("\nVerification:")
for p in check:
    if os.path.exists(p):
        print(f"  OK {p} ({os.path.getsize(p)} bytes)")
    else:
        print(f"  MISSING {p}")