#!/usr/bin/env bash

set -euo pipefail

BOOST_VERSION="${1:-${BOOST_VERSION:-}}"
OUTPUT="${2:-}"

[[ -n "$BOOST_VERSION" ]] || {
    echo "Usage: $0 <boost-version> [output-file]" >&2
    exit 2
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST="$REPO_ROOT/packaging/versions/$BOOST_VERSION-components.tsv"
RELEASE_NOTES="$REPO_ROOT/packaging/versions/$BOOST_VERSION-release.md"
VALIDATION_NOTES="$REPO_ROOT/packaging/versions/$BOOST_VERSION-validation.md"

[[ -s "$MANIFEST" ]] || {
    echo "Missing component manifest: $MANIFEST" >&2
    exit 1
}

BOOST_MINOR="$(printf '%s' "$BOOST_VERSION" | cut -d. -f2)"
if (( BOOST_MINOR <= 64 )); then
    CPPSTD=C++11
elif (( BOOST_MINOR <= 67 )); then
    CPPSTD=C++14
elif (( BOOST_MINOR <= 79 )); then
    CPPSTD=C++17
else
    CPPSTD=C++20
fi

write_notes() {
    cat <<EOF
Boost is a large, peer-reviewed collection of portable C++ libraries that both fills gaps in the standard library and serves as a proving ground for features—many of which (like smart
  pointers, regex, and filesystem) later get adopted into the C++ standard itself.

Precompiled Boost $BOOST_VERSION XCFramework for macOS (x86_64 + arm64). Includes all headers, compiled-component inventories, CMake and pkg-config metadata.

- [Boost $BOOST_VERSION upstream release page](https://www.boost.org/releases/$BOOST_VERSION/)
- C++ language standard: $CPPSTD
- Minimum macOS version: 10.15

## Included compiled libraries

EOF

    awk -F '\t' '$1 == "included" { printf "- `boost_%s` — %s\n", $2, $3 }' \
         "$MANIFEST"

    cat <<'EOF'

All Boost headers are included. Header-only facilities remain available even
when their related compiled library is not part of the combined static binary.
EOF

    if [[ -s "$RELEASE_NOTES" ]]; then
        echo
        echo "## Release features and exclusions"
        echo
        awk '
            NR == 1 { next }
             /^Upstream release:/ { next }
             /^## / { sub(/^## /, "### ") }
             { print }
         ' "$RELEASE_NOTES"
    fi

    if [[ -s "$VALIDATION_NOTES" ]]; then
        echo
        echo "## macOS validation"
        echo
        awk '
            NR == 1 { next }
             /^## / { sub(/^## /, "### ") }
             { print }
         ' "$VALIDATION_NOTES"
    else
        cat <<'EOF'

## macOS build verification

- arm64 (Apple Silicon) and x86_64 (Intel) Universal XCFramework slices
- Standalone package and openFrameworks example
- macOS 10.15+ smoke suite
- pkg-config and CMake package metadata
EOF
    fi
}

if [[ -n "$OUTPUT" ]]; then
    write_notes > "$OUTPUT"
else
    write_notes
fi
