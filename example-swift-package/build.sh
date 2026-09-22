#!/usr/bin/env bash
set -euo pipefail
BOOST_VERSION="${BOOST_VERSION:-1.92.0}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ARCHIVE="${1:?usage: $0 <ofxOSXBoost archive>}"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ofxosxboost-swiftpm.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT
tar -xzf "$ARCHIVE" -C "$WORK_DIR"
cp -R "$SCRIPT_DIR/Package" "$WORK_DIR/Package"
cp -R "$WORK_DIR/ofxOSXBoost-${BOOST_VERSION}/libs/boost/osx/boost.xcframework" "$WORK_DIR/Package/boost.xcframework"
pids=()
for architecture in arm64 x86_64; do
  swift build --package-path "$WORK_DIR/Package" \
    --scratch-path "$WORK_DIR/build-$architecture" \
    -c release --arch "$architecture" &
  pids+=("$!")
done
for pid in "${pids[@]}"; do wait "$pid"; done
echo "SwiftPM consumer passed for arm64 and x86_64."
