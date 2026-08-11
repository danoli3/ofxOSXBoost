# ofxOSXBoost for Boost 1.61.0+ — macOS (deployment target 10.15 / Catalina)

## Boost C++ Libraries — pre-compiled XCFramework for macOS

**Deploy target**: macOS 10.15 (Catalina)  
**Architectures**: x86_64 + arm64 (universal)  
**C++ Standard**: c++11+  

### What is this?

Boost C++ libraries packaged as a static XCFramework for macOS (x86_64 + arm64) using the macOS 10.15+ deployment target. Designed as an openFrameworks addon, but also usable in any C++ project.

### Supported Versions

| Version | Deployment Target | Highlights |
|---------|------------------|------------|
| 1.61.0 | macOS 10.9+ | Original library set |
| 1.62.0 | macOS 10.9+ | Adds `filesystem3` |
| 1.63.0 | macOS 10.9+ | Same libraries |
| 1.64.0 | macOS 10.9+ | Adds `regex_extended`, `signals2` |
| 1.65.0 | macOS 10.15+ | Adds `context`, `coroutine`, `coroutine2`, `call_traits`, `mp11` |
| 1.66.0 | macOS 10.15+ | Adds `callable_traits`, `beast` (experimental HTTP library) |

### Installation

The package structure is flat and relocatable:

- `libs/boost/include/` — complete Boost header tree  
- `libs/boost/lib/` — platform-native `libboost.a` (x86_64 + arm64 fat static)  
- `libs/boost/cmake/` — CMake `find_package` config  
- `ofsxOSXBoost/` — the compiled XCFramework  

### How to Build

You don't need to — pre-compiled libraries are included. If you want to build your own:

```bash
cd ofxOSXBoost
./scripts/build-boost-osx       # default: 1.66.0
BOOST_VERSION=1.65.0 ./scripts/build-boost-osx  # specific version
```

Configure via environment variables:

- **`BOOST_VERSION`** — Boost version to build (default: `1.66.0`, supported: 1.61.0 … 1.66.0)  
- **`BOOST_LIBS`** — space-separated library names (default: `random regex graph chrono thread signals filesystem system date_time`)  
- **`OSX_MIN_VERSION`** — macOS deployment target (default: `10.15`)  
- **`JOBS`** — parallel build threads (default: number of logical CPU cores)  
- **`DIST_DIR`** — output directory for tarballs and XCFramework  

The build script downloads the source from [archives.boost.io](https://archives.boost.io), applies patches for Boost 1.61.0+, builds static libraries, and produces a flat relocatable package.

#### Install Script

Install a released Boost version from the tarball (no rebuild needed):

```bash
./scripts/install-boost 1.66.0
```

### How to Use with openFrameworks

Copy the addon into your project's `addons/` folder. The `addon_config.mk` is already configured to find the XCFramework and headers.

**In Xcode Build Settings:**

1. Add to **Library Search Paths** (`LIBRARY_SEARCH_PATHS`):
   ```
   $(SRCROOT)/../../../addons/ofxOSXBoost/libs/boost/osx
   ```
2. Add to **Header Search Paths** (`HEADER_SEARCH_PATHS`):
   ```
   $(SRCROOT)/../../../addons/ofxOSXBoost/libs/boost/include
   ```

### How to Use in a Standalone Project

**With CMake:**

```cmake
find_package(ofxOSXBoost CONFIG REQUIRED)
target_link_libraries(my_app PRIVATE ofxOSXBoost::boost)
```

Include path is `$SRCROOT/ofxOSXBoost/libs/boost/include`; library path is `$SRCROOT/ofxOSXBoost/libs/boost/lib`.

**With CocoaPods:**

```ruby
pod 'ofxOSXBoost', '~> 1.66.0'
```

### Packaging

The repository includes templates and manifests for multiple distribution formats:

- **CMake** — `packaging/cmake/ofxOSXBoostConfig.cmake.in`  
- **pkg-config** — `packaging/pkgconfig/ofxOSXBoost-osx.pc`  
- **Swift Package Manager** — `packaging/swiftpm/Module/` (module map)  
- **CocoaPods** — `ofxOSXBoost.podspec` + `packaging/cocoapods/`  

### Component Manifests

Library selections evolve by Boost version. Full component manifests are in `packaging/versions/`:

| Manifest | Added / Changed |
|---|---|
| `1.61.0-components.tsv` | Original library set |
| `1.62.0-components.tsv` | Adds `filesystem3` |
| `1.63.0-components.tsv` | Same as 1.62.0 |
| `1.64.0-components.tsv` | Adds `regex_extended`, `signals2` |
| `1.65.0-components.tsv` | Adds `context`, `coroutine`, `coroutine2`, `call_traits`, `mp11` |
| `1.66.0-components.tsv` | Adds `callable_traits`, `beast` (experimental HTTP) |

### License

See the [Boost License](https://www.boost.org/users/license.html) — BSL-1.0. All Boost libraries are licensed under the Boost Software License.

### Build History

| Version | Date |
|---|---|
| 1.66.0 | August 2026 (macOS 10.15, universal x86_64 + arm64) |
| 1.65.0 | C++14 feature set — context, coroutines, Mp11 |
| 1.61.0 | Original macOS release |
