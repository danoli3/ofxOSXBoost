# ofxOSXBoost for Boost 1.92.0 — macOS 10.15+

## Boost C++ Libraries — pre-compiled XCFramework for macOS

**Deploy target**: macOS 10.15 (Catalina)  
**Architectures**: x86_64 + arm64 (universal)  
**C++ Standard**: C++20

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
| 1.67.0 | macOS 10.15+ | Last historical release in the original automation |
| 1.92.0 | macOS 10.15+ | C++20 universal XCFramework, SwiftPM, CocoaPods, and Homebrew |

### Installation

The package structure is flat and relocatable:

- `libs/boost/osx/boost.xcframework/` — complete headers and universal `libboost.a`
- `libs/boost/cmake/` — CMake `find_package` config  

### How to Build

You don't need to — pre-compiled libraries are included. If you want to build your own:

```bash
cd ofxOSXBoost
./scripts/build-boost-osx       # default: 1.92.0
```

Configure via environment variables:

- **`BOOST_VERSION`** — Boost version to build (default: `1.92.0`)
- **`BOOST_LIBS`** — optional space-separated override of the versioned compiled set
- **`OSX_MIN_VERSION`** — macOS deployment target (default: `10.15`)  
- **`JOBS`** — parallel build threads (default: number of logical CPU cores)  
- **`DIST_DIR`** — output directory for tarballs and XCFramework  

The builder verifies the official Boost source SHA-256, compiles arm64 and
x86_64 independently with C++20, creates a universal XCFramework, and emits
checksummed release artifacts.

#### Install Script

Install a released Boost version from the tarball (no rebuild needed):

```bash
./scripts/install-boost 1.92.0
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
pod 'ofxOSXBoost', '~> 1.92.0'
```

### Packaging

The repository includes templates and manifests for multiple distribution formats:

- **CMake** — `packaging/cmake/ofxOSXBoostConfig.cmake.in`  
- **pkg-config** — `packaging/pkgconfig/ofxOSXBoost-osx.pc`  
- **Swift Package Manager** — root `Package.swift` plus a two-architecture consumer gate
- **CocoaPods** — `ofxOSXBoost.podspec` + `packaging/cocoapods/`  
- **Homebrew** — audited formula template in `packaging/homebrew/`

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
| `1.92.0-components.tsv` | C++20 compiled set and explicit exclusions |

### License

See the [Boost License](https://www.boost.org/users/license.html) — BSL-1.0. All Boost libraries are licensed under the Boost Software License.

### Build History

| Version | Date |
|---|---|
| 1.92.0 | August 2026 (C++20, macOS 10.15, universal x86_64 + arm64) |
| 1.66.0 | August 2026 (macOS 10.15, universal x86_64 + arm64) |
| 1.65.0 | C++14 feature set — context, coroutines, Mp11 |
| 1.61.0 | Original macOS release |
