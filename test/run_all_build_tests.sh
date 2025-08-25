#!/bin/bash

# Master Test Runner for usbX Build System
# Runs all comprehensive TDD tests for the build system

set -e

# Change to project root directory
cd "$(dirname "$0")/.."

echo "========================================="
echo "    usbX BUILD SYSTEM COMPREHENSIVE TESTS"
echo "========================================="
echo

# Function to run a test and track results
run_test() {
    local test_script="$1"
    local test_name="$2"
    
    echo ">>> Running $test_name..."
    echo
    
    if ./"$test_script"; then
        echo "✅ $test_name: PASSED"
    else
        echo "❌ $test_name: FAILED"
        echo "Test failed: $test_script"
        exit 1
    fi
    
    echo
    echo "----------------------------------------"
    echo
}

# Original basic build test
run_test "test/test_build.sh" "Basic Build Tests"

# New comprehensive test suites
run_test "test/test_build_dependency_failures.sh" "Dependency Failure Tests"
run_test "test/test_build_invalid_source.sh" "Invalid Source File Tests"
run_test "test/test_build_missing_files.sh" "Missing Files/Directories Tests"
run_test "test/test_build_targets.sh" "Build Target Tests"
run_test "test/test_build_edge_cases.sh" "Edge Cases Tests"

echo "========================================="
echo "    ALL BUILD SYSTEM TESTS COMPLETED"
echo "========================================="
echo
echo "✅ All test suites passed successfully!"
echo
echo "Test Coverage Summary:"
echo "  • Basic build functionality"
echo "  • Dependency detection and fallback"
echo "  • Invalid source code handling"
echo "  • Missing files and directories"
echo "  • Build target behavior"
echo "  • Edge cases and special scenarios"
echo
echo "The usbX build system is robust and handles"
echo "all tested edge cases appropriately!"