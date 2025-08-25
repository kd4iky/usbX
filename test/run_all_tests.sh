#!/bin/bash

# Comprehensive test runner for usbX project
# This script runs all available tests from the test directory

set -e

# Change to project root
cd "$(dirname "$0")/.."

echo "=== usbX Test Suite ==="
echo "Running comprehensive test suite for usbX microservice"
echo

# Check if test scripts exist
TESTS=(
    "test/test_build.sh"
    "test/test_uthash.sh"
)

for test_script in "${TESTS[@]}"; do
    if [ ! -f "$test_script" ]; then
        echo "ERROR: Test script $test_script not found"
        exit 1
    fi
    if [ ! -x "$test_script" ]; then
        echo "ERROR: Test script $test_script is not executable"
        exit 1
    fi
done

# Run tests
echo "Found ${#TESTS[@]} test scripts"
echo

TEST_COUNT=0
PASSED_COUNT=0

for test_script in "${TESTS[@]}"; do
    echo "----------------------------------------"
    echo "Running: $test_script"
    echo "----------------------------------------"
    
    if "./$test_script"; then
        echo "✓ PASSED: $test_script"
        ((PASSED_COUNT++))
    else
        echo "✗ FAILED: $test_script"
    fi
    
    ((TEST_COUNT++))
    echo
done

echo "========================================"
echo "TEST SUMMARY"
echo "========================================"
echo "Tests run: $TEST_COUNT"
echo "Passed: $PASSED_COUNT"
echo "Failed: $((TEST_COUNT - PASSED_COUNT))"

if [ $PASSED_COUNT -eq $TEST_COUNT ]; then
    echo
    echo "🎉 ALL TESTS PASSED! 🎉"
    echo "The usbX project is ready for development!"
    exit 0
else
    echo
    echo "❌ Some tests failed. Please fix issues before proceeding."
    exit 1
fi