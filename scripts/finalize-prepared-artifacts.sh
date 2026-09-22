#!/usr/bin/env bash
set -euo pipefail
BOOST_VERSION="$1"
DIST_DIR="$(cd "$2" && pwd)"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NAME="ofxOSXBoost-$BOOST_VERSION"
work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
tar -xzf "$DIST_DIR/$NAME.tar.gz" -C "$work"
old="$work/$NAME"
stage="$work/stage"; mkdir -p "$stage"
git -C "$ROOT" archive --prefix="$NAME/" HEAD | tar -xf - -C "$stage"
target="$stage/$NAME"
rm -rf "$target/libs/boost/include" "$target/libs/boost/osx"
mkdir -p "$target/libs/boost/osx"
ditto -x -k "$DIST_DIR/$NAME-xcframework.zip" "$target/libs/boost/osx"
for f in LICENSE_1_0.txt BUILD-INFO.txt COMPONENTS.md RELEASE-NOTES.md VALIDATION.md; do [[ -s "$old/$f" ]] && cp "$old/$f" "$target/$f"; done
tar -czf "$DIST_DIR/$NAME.tar.gz" -C "$stage" "$NAME"
sha="$(shasum -a 256 "$DIST_DIR/$NAME.tar.gz" | awk '{print $1}')"
sed -e "s|@BOOST_VERSION@|$BOOST_VERSION|g" -e "s|@ARCHIVE_SHA@|$sha|g" "$ROOT/packaging/cocoapods/ofxOSXBoost.podspec.in" > "$DIST_DIR/ofxOSXBoost.podspec"
sed -e "s|@BOOST_VERSION@|$BOOST_VERSION|g" -e "s|@ARCHIVE_SHA@|$sha|g" "$ROOT/packaging/homebrew/ofxOSXBoost.rb.in" > "$DIST_DIR/ofxOSXBoost.rb"
(cd "$DIST_DIR" && shasum -a 256 "$NAME.tar.gz" > "$NAME.tar.gz.sha256" && shasum -a 256 "$NAME-xcframework.zip" > "$NAME-xcframework.zip.sha256")
