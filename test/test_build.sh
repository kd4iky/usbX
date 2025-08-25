#!/bin/bash

# TDD Test Script for usbX Makefile
# This test verifies that the Makefile can compile src/main.c into an executable

set -e

# Change to project root directory
cd "$(dirname "$0")/.."

echo "=== TDD Build Test for usbX ==="
echo

# Test 1: Check if Makefile exists
echo "Test 1: Checking if Makefile exists..."
if [ ! -f "Makefile" ]; then
    echo "FAIL: Makefile not found"
    exit 1
fi
echo "PASS: Makefile found"

# Test 2: Check if src directory and main.c exist
echo "Test 2: Checking if src/main.c exists..."
if [ ! -f "src/main.c" ]; then
    echo "FAIL: src/main.c not found"
    exit 1
fi
echo "PASS: src/main.c found"

# Test 3: Clean any existing build
echo "Test 3: Cleaning previous build..."
make clean 2>/dev/null || true
echo "PASS: Clean completed"

# Test 4: Run make and check for executable
echo "Test 4: Running make build..."
if ! make; then
    echo "FAIL: Make build failed"
    exit 1
fi
echo "PASS: Make build succeeded"

# Test 5: Check if executable was created
echo "Test 5: Checking if usbx executable exists..."
if [ ! -f "usbx" ]; then
    echo "FAIL: usbx executable not created"
    exit 1
fi
echo "PASS: usbx executable created"

# Test 6: Check if executable is actually executable
echo "Test 6: Checking if usbx is executable..."
if [ ! -x "usbx" ]; then
    echo "FAIL: usbx is not executable"
    exit 1
fi
echo "PASS: usbx is executable"

# Test 7: Test run target (should not crash immediately)
echo "Test 7: Testing run target..."
timeout 2 make run 2>/dev/null || {
    exit_code=$?
    if [ $exit_code -eq 124 ]; then
        echo "PASS: Run target works (timed out as expected)"
    else
        echo "FAIL: Run target failed with exit code $exit_code"
        exit 1
    fi
}

echo
echo "=== ALL TESTS PASSED ==="
echo "Build system is working correctly!"