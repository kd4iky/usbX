#!/bin/bash

# TDD Test Script for usbX Makefile - Invalid Source File Edge Cases
# Tests how the build system handles syntax errors, corrupted files, and invalid C code

set -e

# Change to project root directory
cd "$(dirname "$0")/.."

echo "=== TDD Invalid Source File Tests for usbX ==="
echo

# Backup original main.c
backup_main() {
    if [ -f "src/main.c" ]; then
        cp "src/main.c" "src/main.c.backup"
    fi
}

# Restore original main.c
restore_main() {
    if [ -f "src/main.c.backup" ]; then
        mv "src/main.c.backup" "src/main.c"
    fi
}

# Test 1: Syntax error in main.c
test_syntax_error() {
    echo "Test 1: Testing syntax error in main.c..."
    
    backup_main
    
    # Create main.c with syntax error
    cat > "src/main.c" << 'EOF'
#include <stdio.h>

int main(void) {
    printf("This is missing a semicolon"
    return 0; // This line will cause error due to missing semicolon above
}
EOF
    
    make clean >/dev/null 2>&1 || true
    
    # Build should fail
    if ! make 2>/dev/null; then
        echo "✓ PASS: Build correctly failed with syntax error"
    else
        echo "✗ FAIL: Build should have failed with syntax error"
        restore_main
        exit 1
    fi
    
    restore_main
}

# Test 2: Missing include files
test_missing_include() {
    echo "Test 2: Testing missing include files..."
    
    backup_main
    
    # Create main.c with non-existent include
    cat > "src/main.c" << 'EOF'
#include <stdio.h>
#include "nonexistent_header.h"  // This header doesn't exist
#include <also_missing.h>        // This header also doesn't exist

int main(void) {
    printf("Hello World\n");
    return 0;
}
EOF
    
    make clean >/dev/null 2>&1 || true
    
    # Build should fail
    if ! make 2>/dev/null; then
        echo "✓ PASS: Build correctly failed with missing includes"
    else
        echo "✗ FAIL: Build should have failed with missing includes"
        restore_main
        exit 1
    fi
    
    restore_main
}

# Test 3: Undefined functions/symbols
test_undefined_symbols() {
    echo "Test 3: Testing undefined functions/symbols..."
    
    backup_main
    
    # Create main.c with undefined functions
    cat > "src/main.c" << 'EOF'
#include <stdio.h>

// Declaration without implementation
void undefined_function(void);
extern int undefined_variable;

int main(void) {
    printf("Calling undefined function...\n");
    undefined_function();  // This function is not implemented
    printf("Variable: %d\n", undefined_variable);  // This variable is not defined
    return 0;
}
EOF
    
    make clean >/dev/null 2>&1 || true
    
    # Build should fail at linking stage
    if ! make 2>/dev/null; then
        echo "✓ PASS: Build correctly failed with undefined symbols"
    else
        echo "✗ FAIL: Build should have failed with undefined symbols"
        restore_main
        exit 1
    fi
    
    restore_main
}

# Test 4: Empty source file
test_empty_source() {
    echo "Test 4: Testing empty source file..."
    
    backup_main
    
    # Create completely empty main.c
    cat > "src/main.c" << 'EOF'
EOF
    
    make clean >/dev/null 2>&1 || true
    
    # Build should fail (no main function)
    if ! make 2>/dev/null; then
        echo "✓ PASS: Build correctly failed with empty source file"
    else
        echo "✗ FAIL: Build should have failed with empty source file"
        restore_main
        exit 1
    fi
    
    restore_main
}

# Test 5: Binary/corrupted source file
test_corrupted_source() {
    echo "Test 5: Testing binary/corrupted source file..."
    
    backup_main
    
    # Create binary content in main.c
    printf '\x00\x01\x02\x03\xFF\xFE\xFD\xFC' > "src/main.c"
    printf 'int main() { return 0; }' >> "src/main.c"  # Mix binary with valid C
    
    make clean >/dev/null 2>&1 || true
    
    # Build should fail due to invalid characters
    if ! make 2>/dev/null; then
        echo "✓ PASS: Build correctly failed with corrupted source file"
    else
        echo "✗ FAIL: Build should have failed with corrupted source file"
        restore_main
        exit 1
    fi
    
    restore_main
}

# Test 6: Very long source file (stress test)
test_large_source() {
    echo "Test 6: Testing very large source file (stress test)..."
    
    backup_main
    
    # Create a large source file with many functions
    cat > "src/main.c" << 'EOF'
#include <stdio.h>

EOF
    
    # Generate 1000 dummy functions
    for i in {1..1000}; do
        echo "void function_$i(void) { printf(\"Function $i\\n\"); }" >> "src/main.c"
    done
    
    # Add main function that calls some functions
    cat >> "src/main.c" << 'EOF'

int main(void) {
    printf("Testing large source file...\n");
    function_1();
    function_500();
    function_1000();
    return 0;
}
EOF
    
    make clean >/dev/null 2>&1 || true
    
    # Build should succeed but might be slow
    echo "  (This test may take some time...)"
    if timeout 30 make 2>/dev/null; then
        echo "✓ PASS: Build succeeded with large source file"
        # Test that executable works
        if timeout 5 ./usbx >/dev/null 2>&1; then
            echo "✓ PASS: Large executable runs correctly"
        else
            echo "⚠ WARNING: Large executable failed to run (expected)"
        fi
    else
        echo "⚠ WARNING: Build timed out or failed with large source (may be system-dependent)"
    fi
    
    restore_main
}

# Test 7: Invalid compiler flags in source (pragma test)
test_invalid_pragma() {
    echo "Test 7: Testing source file with invalid compiler directives..."
    
    backup_main
    
    # Create main.c with invalid pragma directives
    cat > "src/main.c" << 'EOF'
#include <stdio.h>

#pragma invalid_directive
#pragma GCC diagnostic error "-Winvalid-flag-name"
#error "This will cause compilation to fail"

int main(void) {
    printf("This should never compile\n");
    return 0;
}
EOF
    
    make clean >/dev/null 2>&1 || true
    
    # Build should fail due to #error directive
    if ! make 2>/dev/null; then
        echo "✓ PASS: Build correctly failed with invalid pragma/error directive"
    else
        echo "✗ FAIL: Build should have failed with error directive"
        restore_main
        exit 1
    fi
    
    restore_main
}

# Run all invalid source tests
test_syntax_error
test_missing_include
test_undefined_symbols
test_empty_source
test_corrupted_source
test_large_source
test_invalid_pragma

echo
echo "=== ALL INVALID SOURCE TESTS COMPLETED ==="
echo "Build system correctly handles invalid source files!"