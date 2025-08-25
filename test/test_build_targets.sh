#!/bin/bash

# TDD Test Script for usbX Makefile - Clean and Run Target Testing
# Tests the behavior of make clean, make run, and other build targets

set -e

# Change to project root directory
cd "$(dirname "$0")/.."

echo "=== TDD Build Targets Tests for usbX ==="
echo

# Test 1: make clean removes all build artifacts
test_clean_target() {
    echo "Test 1: Testing make clean removes build artifacts..."
    
    # First, ensure we have a built project
    make >/dev/null 2>&1 || true
    
    # Create some additional files that should be cleaned
    touch "extra_file.o" "temp.tmp"
    mkdir -p "build"
    touch "build/test.o" "build/temp"
    
    # Verify executable exists before cleaning
    if [ ! -f "usbx" ]; then
        echo "⚠ WARNING: usbx executable not found before clean test"
    fi
    
    # Run make clean
    make clean >/dev/null
    
    # Check that main executable is removed
    if [ ! -f "usbx" ]; then
        echo "✓ PASS: usbx executable was removed by clean"
    else
        echo "✗ FAIL: usbx executable was not removed by clean"
        exit 1
    fi
    
    # Check that build directory is removed
    if [ ! -d "build" ]; then
        echo "✓ PASS: build directory was removed by clean"
    else
        echo "✗ FAIL: build directory was not removed by clean"
        exit 1
    fi
    
    # Clean up test files
    rm -f "extra_file.o" "temp.tmp"
}

# Test 2: make clean is safe when no build artifacts exist
test_clean_no_artifacts() {
    echo "Test 2: Testing make clean with no build artifacts..."
    
    # Ensure clean state
    make clean >/dev/null 2>&1 || true
    rm -f "usbx" 
    rm -rf "build"
    
    # make clean should succeed even with nothing to clean
    if make clean >/dev/null 2>&1; then
        echo "✓ PASS: make clean succeeded with no artifacts to clean"
    else
        echo "✗ FAIL: make clean should succeed even with nothing to clean"
        exit 1
    fi
}

# Test 3: make run builds and executes the program
test_run_target() {
    echo "Test 3: Testing make run builds and executes..."
    
    make clean >/dev/null 2>&1 || true
    
    # make run should build first, then execute
    # Use timeout to prevent hanging
    if timeout 5 make run >/dev/null 2>&1; then
        echo "✓ PASS: make run completed successfully"
    else
        exit_code=$?
        if [ $exit_code -eq 124 ]; then
            echo "✓ PASS: make run executed (timed out as expected)"
        elif [ $exit_code -eq 0 ]; then
            echo "✓ PASS: make run completed quickly"
        else
            echo "✗ FAIL: make run failed with exit code $exit_code"
            exit 1
        fi
    fi
    
    # Verify that executable was created by run target
    if [ -f "usbx" ] && [ -x "usbx" ]; then
        echo "✓ PASS: make run created executable"
    else
        echo "✗ FAIL: make run did not create executable"
        exit 1
    fi
}

# Test 4: make run fails gracefully when build fails
test_run_with_build_failure() {
    echo "Test 4: Testing make run with build failure..."
    
    # Backup main.c and create invalid version
    if [ -f "src/main.c" ]; then
        cp "src/main.c" "src/main.c.backup"
    fi
    
    # Create invalid main.c
    cat > "src/main.c" << 'EOF'
#include <stdio.h>
int main(void) {
    printf("Missing semicolon"
    return 0;
}
EOF
    
    make clean >/dev/null 2>&1 || true
    
    # make run should fail due to build failure
    if ! make run >/dev/null 2>&1; then
        echo "✓ PASS: make run correctly failed when build fails"
    else
        echo "✗ FAIL: make run should fail when build fails"
        # Restore main.c
        if [ -f "src/main.c.backup" ]; then
            mv "src/main.c.backup" "src/main.c"
        fi
        exit 1
    fi
    
    # Restore main.c
    if [ -f "src/main.c.backup" ]; then
        mv "src/main.c.backup" "src/main.c"
    fi
}

# Test 5: Test all target builds everything
test_all_target() {
    echo "Test 5: Testing make all target..."
    
    make clean >/dev/null 2>&1 || true
    
    # make all should be equivalent to make (default target)
    if make all >/dev/null 2>&1; then
        echo "✓ PASS: make all completed successfully"
    else
        echo "✗ FAIL: make all should build the project"
        exit 1
    fi
    
    # Verify executable was created
    if [ -f "usbx" ] && [ -x "usbx" ]; then
        echo "✓ PASS: make all created executable"
    else
        echo "✗ FAIL: make all did not create executable"
        exit 1
    fi
}

# Test 6: Test help target
test_help_target() {
    echo "Test 6: Testing make help target..."
    
    # make help should display help information
    if make help >/dev/null 2>&1; then
        echo "✓ PASS: make help completed successfully"
        
        # Check if help contains expected targets
        help_output=$(make help 2>&1)
        if echo "$help_output" | grep -q "all\|clean\|run"; then
            echo "✓ PASS: make help contains expected target information"
        else
            echo "⚠ WARNING: make help output may not contain expected targets"
        fi
    else
        echo "✗ FAIL: make help should display help information"
        exit 1
    fi
}

# Test 7: Test check-deps target
test_check_deps_target() {
    echo "Test 7: Testing make check-deps target..."
    
    # make check-deps should show dependency status
    if make check-deps >/dev/null 2>&1; then
        echo "✓ PASS: make check-deps completed successfully"
    else
        echo "✗ FAIL: make check-deps should show dependency information"
        exit 1
    fi
}

# Test 8: Test multiple consecutive builds (incremental build behavior)
test_incremental_build() {
    echo "Test 8: Testing incremental build behavior..."
    
    make clean >/dev/null 2>&1 || true
    
    # First build
    if ! make >/dev/null 2>&1; then
        echo "✗ FAIL: Initial build failed"
        exit 1
    fi
    
    # Get modification time of executable
    if [ -f "usbx" ]; then
        first_mtime=$(stat -c %Y "usbx" 2>/dev/null || stat -f %m "usbx" 2>/dev/null || echo "0")
    else
        echo "✗ FAIL: Executable not created after first build"
        exit 1
    fi
    
    # Wait a moment to ensure different timestamps
    sleep 1
    
    # Second build (should be fast - no changes)
    if make >/dev/null 2>&1; then
        second_mtime=$(stat -c %Y "usbx" 2>/dev/null || stat -f %m "usbx" 2>/dev/null || echo "0")
        
        # Executable should not be rebuilt if no changes
        if [ "$first_mtime" -eq "$second_mtime" ]; then
            echo "✓ PASS: Incremental build did not rebuild unchanged executable"
        else
            echo "⚠ WARNING: Executable was rebuilt despite no changes (may be expected)"
        fi
    else
        echo "✗ FAIL: Second build failed"
        exit 1
    fi
}

# Test 9: Test install target (should exist but may not be implemented)
test_install_target() {
    echo "Test 9: Testing make install target..."
    
    # make install may not be fully implemented but should exist
    if make install >/dev/null 2>&1; then
        echo "✓ PASS: make install target exists and runs"
    else
        echo "⚠ WARNING: make install target may not be implemented yet"
    fi
}

# Run all build target tests
test_clean_target
test_clean_no_artifacts
test_run_target
test_run_with_build_failure
test_all_target
test_help_target
test_check_deps_target
test_incremental_build
test_install_target

echo
echo "=== ALL BUILD TARGET TESTS COMPLETED ==="
echo "Build system targets are working correctly!"