#!/bin/bash

# Cats Test Runner
# Runs tests for all SPM packages with test targets

set -o pipefail

# Parse arguments
VERBOSE=false
INCLUDE_APP=false
INCLUDE_UI=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose) VERBOSE=true; shift ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -v, --verbose    Show detailed test output"
            echo "  -h, --help       Show this help"
            echo ""
            echo "Examples:"
            echo "  $0               # Run all SPM package tests"
            echo "  $0 -v            # Run with detailed output"
            exit 0
            ;;
        *) echo "Unknown option: $1 (use -h for help)"; exit 1 ;;
    esac
done

echo "🧪 Running Cats Tests"
echo ""

# Find iPhone simulator (explicitly exclude real devices)
SIMULATOR=$(xcrun simctl list devices available 2>/dev/null | grep "iPhone" | grep -v "unavailable" | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')

if [ -z "$SIMULATOR" ]; then
    echo "❌ No iPhone simulator found"
    echo "Please install iOS simulators via Xcode > Settings > Platforms"
    exit 1
fi

SIMULATOR_NAME=$(xcrun simctl list devices 2>/dev/null | grep "$SIMULATOR" | sed -E 's/^ +//' | sed 's/ (.*//')
echo "Using simulator: $SIMULATOR_NAME"
echo ""

# Track results
PASSED=()
FAILED=()
START_TIME=$(date +%s)

# Test a package
test_package() {
    local name=$1
    local path=$2

    echo "📦 Testing $name..."

    cd "$path" || { echo "❌ Directory not found: $path"; FAILED+=("$name"); return; }

    local result
    if [ "$VERBOSE" = true ]; then
        xcodebuild test \
            -scheme "$name" \
            -destination "platform=iOS Simulator,id=$SIMULATOR" \
            -only-testing:"${name}Tests" 2>&1 | grep -v "Ineligible destinations"
        result=${PIPESTATUS[0]}
    else
        xcodebuild test \
            -scheme "$name" \
            -destination "platform=iOS Simulator,id=$SIMULATOR" \
            -only-testing:"${name}Tests" \
            -quiet 2>&1 | grep -v "Ineligible destinations"
        result=${PIPESTATUS[0]}
    fi

    if [ $result -eq 0 ]; then
        echo "✅ $name"
        PASSED+=("$name")
    else
        echo "❌ $name"
        FAILED+=("$name")
    fi

    cd - > /dev/null
    echo ""
}

# Test main app
test_app() {
    echo "🏗️  Testing Cats (main app)..."

    local result
    if [ "$VERBOSE" = true ]; then
        xcodebuild test \
            -project Cats/Cats.xcodeproj \
            -scheme Cats \
            -destination "platform=iOS Simulator,id=$SIMULATOR" 2>&1 | grep -v "Ineligible destinations"
        result=${PIPESTATUS[0]}
    else
        xcodebuild test \
            -project Cats/Cats.xcodeproj \
            -scheme Cats \
            -destination "platform=iOS Simulator,id=$SIMULATOR" \
            -quiet 2>&1 | grep -v "Ineligible destinations"
        result=${PIPESTATUS[0]}
    fi

    if [ $result -eq 0 ]; then
        echo "✅ Cats"
        PASSED+=("Cats")
    else
        echo "❌ Cats"
        FAILED+=("Cats")
    fi
    echo ""
}

# Test UI tests
test_ui() {
    echo "📱 Testing CatsUITests..."

    local UI_SIMULATOR=$(xcrun simctl list devices 2>/dev/null | grep "iPhone 17" | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')

    if [ -z "$UI_SIMULATOR" ]; then
        echo "❌ No iPhone 17 simulator found for UI tests"
        FAILED+=("CatsUITests")
        return
    fi

    local UI_SIMULATOR_NAME=$(xcrun simctl list devices 2>/dev/null | grep "$UI_SIMULATOR" | sed -E 's/^ +//' | sed 's/ (.*//')
    echo "Using simulator for UI tests: $UI_SIMULATOR_NAME"

    local result
    if [ "$VERBOSE" = true ]; then
        xcodebuild test \
            -project Cats/Cats.xcodeproj \
            -scheme Cats \
            -destination "platform=iOS Simulator,id=$UI_SIMULATOR" \
            -only-testing:CatsUITests 2>&1 | grep -v "Ineligible destinations"
        result=${PIPESTATUS[0]}
    else
        xcodebuild test \
            -project Cats/Cats.xcodeproj \
            -scheme Cats \
            -destination "platform=iOS Simulator,id=$UI_SIMULATOR" \
            -only-testing:CatsUITests \
            -quiet 2>&1 | grep -v "Ineligible destinations"
        result=${PIPESTATUS[0]}
    fi

    if [ $result -eq 0 ]; then
        echo "✅ CatsUITests"
        PASSED+=("CatsUITests")
    else
        echo "❌ CatsUITests"
        FAILED+=("CatsUITests")
    fi
    echo ""
}

# Run tests
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

test_package "CoreBreeds" "$SCRIPT_DIR/CoreBreeds"
test_package "FeatureBreedsList" "$SCRIPT_DIR/FeatureBreedsList"
test_package "FeatureBreedDetail" "$SCRIPT_DIR/FeatureBreedDetail"
test_package "FeatureFavourites" "$SCRIPT_DIR/FeatureFavourites"
test_ui

# Summary
DURATION=$(($(date +%s) - START_TIME))

echo "════════════════════════════════════"
echo "📊 Summary"
echo "════════════════════════════════════"
echo "Passed: ${#PASSED[@]}"
echo "Failed: ${#FAILED[@]}"
echo "Duration: ${DURATION}s"
echo ""

if [ ${#PASSED[@]} -gt 0 ]; then
    echo "✅ Passed:"
    printf '   - %s\n' "${PASSED[@]}"
    echo ""
fi

if [ ${#FAILED[@]} -gt 0 ]; then
    echo "❌ Failed:"
    printf '   - %s\n' "${FAILED[@]}"
    echo ""
    exit 1
fi

echo "🎉 All tests passed!"
exit 0
