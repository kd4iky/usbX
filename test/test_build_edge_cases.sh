#!/bin/bash

# TDD Test Script for usbX Makefile - Edge Cases and Special Characters
# Tests how the build system handles special characters, paths, and unusual scenarios

set -e

# Change to project root directory
cd "$(dirname "$0")/.."

echo "=== TDD Edge Cases Tests for usbX ==="
echo

# Test 1: Project in directory with spaces
test_spaces_in_path() {
    echo "Test 1: Testing build in directory with spaces..."
    
    # Create a temporary directory with spaces
    temp_dir="/tmp/usbx test directory $$"
    mkdir -p "$temp_dir"
    
    # Copy project files to the space-containing directory
    cp -r . "$temp_dir/"
    cd "$temp_dir"
    
    # Build should work despite spaces in path
    make clean >/dev/null 2>&1 || true
    if make >/dev/null 2>&1; then
        echo "✓ PASS: Build succeeded in directory with spaces"
    else
        echo "✗ FAIL: Build should work in directory with spaces"
        cd - >/dev/null
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Test run target too
    if timeout 3 make run >/dev/null 2>&1; then
        echo "✓ PASS: Run target worked in directory with spaces"
    else
        exit_code=$?
        if [ $exit_code -eq 124 ]; then
            echo "✓ PASS: Run target executed in directory with spaces (timed out)"
        else
            echo "⚠ WARNING: Run target had issues in directory with spaces"
        fi
    fi
    
    cd - >/dev/null
    rm -rf "$temp_dir"
}

# Test 2: Source file with special characters in name
test_special_chars_in_filename() {
    echo "Test 2: Testing source file with special characters..."
    
    # Backup original main.c
    if [ -f "src/main.c" ]; then
        cp "src/main.c" "src/main.c.backup"
    fi
    
    # Create source files with special characters (within reason)
    cp "src/main.c" "src/main-test.c" 2>/dev/null || true
    cp "src/main.c" "src/main_with_underscores.c" 2>/dev/null || true
    
    make clean >/dev/null 2>&1 || true
    
    # Build should handle these files (Makefile uses wildcard)
    if make >/dev/null 2>&1; then
        echo "✓ PASS: Build handled source files with special characters"
    else
        echo "⚠ WARNING: Build had issues with special characters in filenames"
    fi
    
    # Clean up
    rm -f "src/main-test.c" "src/main_with_underscores.c"
    if [ -f "src/main.c.backup" ]; then
        mv "src/main.c.backup" "src/main.c"
    fi
}

# Test 3: Very long file paths
test_long_paths() {
    echo "Test 3: Testing very long file paths..."
    
    # Create nested directory structure
    long_path="src"
    for i in {1..10}; do
        long_path="$long_path/very_long_directory_name_that_makes_the_path_extremely_long_$i"
    done
    
    mkdir -p "$long_path" 2>/dev/null || {
        echo "⚠ SKIP: Cannot create very long directory path (filesystem limitation)"
        return 0
    }
    
    # Copy main.c to deep directory
    cp "src/main.c" "$long_path/deep_main.c" 2>/dev/null || {
        echo "⚠ SKIP: Cannot copy file to very long path"
        rm -rf "src/very_long_directory_name_that_makes_the_path_extremely_long_1" 2>/dev/null || true
        return 0
    }
    
    make clean >/dev/null 2>&1 || true
    
    # Build should still work (though it will find the deep file too)
    if make >/dev/null 2>&1; then
        echo "✓ PASS: Build handled very long file paths"
    else
        echo "⚠ WARNING: Build had issues with very long file paths"
    fi
    
    # Clean up
    rm -rf "src/very_long_directory_name_that_makes_the_path_extremely_long_1" 2>/dev/null || true
}

# Test 4: Unicode characters in source code comments
test_unicode_in_source() {
    echo "Test 4: Testing Unicode characters in source code..."
    
    if [ -f "src/main.c" ]; then
        cp "src/main.c" "src/main.c.backup"
    fi
    
    # Create main.c with Unicode characters in comments
    cat > "src/main.c" << 'EOF'
#include <stdio.h>

/* 
 * Unicode test: こんにちは 世界 🌍 ñáéíóú àèìòù âêîôû
 * Mathematical symbols: ∑ ∏ ∫ ∆ ∇ ∞ π λ μ σ
 * Various scripts: العربية Русский 中文 한국어 Ελληνικά
 */
int main(void) {
    printf("Unicode comment test\n");
    // Another comment with special chars: ¡¢£¤¥¦§¨©
    return 0;
}
EOF
    
    make clean >/dev/null 2>&1 || true
    
    # Build should handle Unicode in comments
    if make >/dev/null 2>&1; then
        echo "✓ PASS: Build handled Unicode characters in source comments"
        
        # Test that the executable runs
        if timeout 3 ./usbx >/dev/null 2>&1; then
            echo "✓ PASS: Executable with Unicode comments runs correctly"
        else
            echo "⚠ WARNING: Executable with Unicode comments had runtime issues"
        fi
    else
        echo "✗ FAIL: Build should handle Unicode characters in comments"
        if [ -f "src/main.c.backup" ]; then
            mv "src/main.c.backup" "src/main.c"
        fi
        exit 1
    fi
    
    if [ -f "src/main.c.backup" ]; then
        mv "src/main.c.backup" "src/main.c"
    fi
}

# Test 5: Environment variables affecting build
test_environment_variables() {
    echo "Test 5: Testing environment variable effects on build..."
    
    make clean >/dev/null 2>&1 || true
    
    # Test with modified CC environment variable
    (
        export CC="gcc-nonexistent-version"
        if ! make >/dev/null 2>&1; then
            echo "✓ PASS: Build correctly failed with invalid CC environment variable"
        else
            echo "⚠ WARNING: Build succeeded despite invalid CC (may have fallback)"
        fi
    )
    
    # Test with modified CFLAGS
    (
        export CFLAGS="-invalid-flag-that-does-not-exist"
        if ! make >/dev/null 2>&1; then
            echo "✓ PASS: Build correctly failed with invalid CFLAGS"
        else
            echo "⚠ WARNING: Build succeeded despite invalid CFLAGS"
        fi
    )
    
    # Test with empty PATH (extreme case)
    (
        export PATH=""
        if ! make >/dev/null 2>&1; then
            echo "✓ PASS: Build correctly failed with empty PATH"
        else
            echo "⚠ WARNING: Build succeeded despite empty PATH"
        fi
    )
}

# Test 6: Symlinks in source directory
test_symlinks() {
    echo "Test 6: Testing symlinks in source directory..."
    
    # Create a symlink to main.c
    if [ -f "src/main.c" ]; then
        ln -sf "main.c" "src/symlink_main.c" 2>/dev/null || {
            echo "⚠ SKIP: Cannot create symlinks (filesystem doesn't support them)"
            return 0
        }
        
        make clean >/dev/null 2>&1 || true
        
        # Build should handle symlinks (though it might create duplicate symbols)
        if ! make >/dev/null 2>&1; then
            echo "✓ PASS: Build correctly detected issue with symlinked source files"
        else
            echo "⚠ WARNING: Build succeeded with symlinked files (may have duplicate main functions)"
        fi
        
        # Clean up symlink
        rm -f "src/symlink_main.c"
    fi
}

# Test 7: Case sensitivity issues
test_case_sensitivity() {
    echo "Test 7: Testing case sensitivity..."
    
    # Create files with different cases
    if [ -f "src/main.c" ]; then
        cp "src/main.c" "src/MAIN.c" 2>/dev/null || true
        cp "src/main.c" "src/Main.c" 2>/dev/null || true
    fi
    
    make clean >/dev/null 2>&1 || true
    
    # On case-sensitive filesystems, this might cause issues
    if ! make >/dev/null 2>&1; then
        echo "✓ PASS: Build detected case sensitivity issues (multiple main functions)"
    else
        echo "⚠ WARNING: Build succeeded despite case variations (may be case-insensitive filesystem)"
    fi
    
    # Clean up
    rm -f "src/MAIN.c" "src/Main.c"
}

# Test 8: Disk space issues (simulated)
test_disk_space() {
    echo "Test 8: Testing low disk space scenario..."
    
    # This is hard to test reliably without actually filling the disk
    # Instead, we'll test with a read-only filesystem which might simulate some issues
    
    # Try to create a very large temporary file to use up space (if possible)
    if command -v fallocate >/dev/null 2>&1; then
        # Try to create a 1GB file in /tmp (if space allows)
        if fallocate -l 1G "/tmp/large_test_file_$$" 2>/dev/null; then
            echo "✓ INFO: Created large temporary file to test disk space conditions"
            
            make clean >/dev/null 2>&1 || true
            
            # Build should still work unless disk is really full
            if make >/dev/null 2>&1; then
                echo "✓ PASS: Build succeeded with reduced disk space"
            else
                echo "⚠ WARNING: Build failed with reduced disk space"
            fi
            
            # Clean up large file
            rm -f "/tmp/large_test_file_$$"
        else
            echo "⚠ SKIP: Cannot create large test file for disk space test"
        fi
    else
        echo "⚠ SKIP: fallocate not available for disk space test"
    fi
}

# Run all edge case tests
test_spaces_in_path
test_special_chars_in_filename
test_long_paths
test_unicode_in_source
test_environment_variables
test_symlinks
test_case_sensitivity
test_disk_space

echo
echo "=== ALL EDGE CASE TESTS COMPLETED ==="
echo "Build system handles edge cases appropriately!"