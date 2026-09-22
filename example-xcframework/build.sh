#!/usr/bin/env bash
set -euo pipefail
BOOST_VERSION="${BOOST_VERSION:-1.92.0}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ARCHIVE="${1:-}"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ofxosxboost-example.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT
if [[ -z "$ARCHIVE" ]]; then
  ARCHIVE="$WORK_DIR/ofxOSXBoost-${BOOST_VERSION}.tar.gz"
  RELEASE_URL="https://github.com/danoli3/ofxOSXBoost/releases/download/${BOOST_VERSION}"
  curl --fail --location --retry 3 "$RELEASE_URL/$(basename "$ARCHIVE")" --output "$ARCHIVE"
  curl --fail --location --retry 3 "$RELEASE_URL/$(basename "$ARCHIVE").sha256" --output "$ARCHIVE.sha256"
  (cd "$WORK_DIR" && shasum -a 256 -c "$(basename "$ARCHIVE").sha256")
else
  ARCHIVE="$(cd "$(dirname "$ARCHIVE")" && pwd)/$(basename "$ARCHIVE")"
fi
tar -xzf "$ARCHIVE" -C "$WORK_DIR"
PACKAGE="$WORK_DIR/ofxOSXBoost-${BOOST_VERSION}"
FRAMEWORK="$PACKAGE/libs/boost/osx/boost.xcframework"
SLICE="$FRAMEWORK/macos-arm64_x86_64"
LIBRARY="$SLICE/libboost.a"
HEADERS="$SLICE/Headers"
plutil -lint "$FRAMEWORK/Info.plist" >/dev/null
archs="$(xcrun lipo -archs "$LIBRARY")"
[[ "$archs" == "x86_64 arm64" || "$archs" == "arm64 x86_64" ]]
for metadata in "$SLICE/boost.pkl" "$SLICE/boost-components.txt" \
  "$PACKAGE/COMPONENTS.md" "$PACKAGE/BUILD-INFO.txt" \
  "$PACKAGE/libs/boost/cmake/ofxOSXBoost/ofxOSXBoostConfig.cmake" \
  "$PACKAGE/libs/boost/pkgconfig/ofxOSXBoost-osx.pc"; do
  [[ -s "$metadata" ]] || { echo "Missing metadata: $metadata" >&2; exit 1; }
done
SDK="$(xcrun --sdk macosx --show-sdk-path)"
for architecture in arm64 x86_64; do
  output="$WORK_DIR/ofxOSXBoost-smoke-$architecture"
  xcrun --sdk macosx clang++ -arch "$architecture" -isysroot "$SDK" \
    -mmacosx-version-min=10.15 -std=c++20 -stdlib=libc++ \
    -I"$HEADERS" "$SCRIPT_DIR/main.cpp" "$LIBRARY" -o "$output"
  [[ "$(xcrun lipo -archs "$output")" == "$architecture" ]]
done
"$WORK_DIR/ofxOSXBoost-smoke-$(uname -m)"
echo "Boost $BOOST_VERSION XCFramework consumer passed for arm64 and x86_64."
