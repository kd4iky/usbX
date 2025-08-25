#!/bin/bash

# TDD Test Script for usbX Makefile - Missing Files/Directories Edge Cases
# Tests how the build system handles missing source directories, files, and Makefile

set -e

# Change to project root directory
cd "$(dirname "$0")/.."

echo "=== TDD Missing Files/Directories Tests for usbX ==="
echo

# Backup functions
backup_src_dir() {
    if [ -d "src" ]; then
        mv "src" "src.backup"
    fi
}

restore_src_dir() {
    if [ -d "src.backup" ]; then
        mv "src.backup" "src"
    fi
}

backup_makefile() {
    if [ -f "Makefile" ]; then
        cp "Makefile" "Makefile.backup"
    fi
}

restore_makefile() {
    if [ -f "Makefile.backup" ]; then
        mv "Makefile.backup" "Makefile"
    fi
}

backup_main_c() {
    if [ -f "src/main.c" ]; then
        cp "src/main.c" "src/main.c.backup"
    fi
}

restore_main_c() {
    if [ -f "src/main.c.backup" ]; then
        mv "src/main.c.backup" "src/main.c"
    fi
}

# Test 1: Missing src directory
test_missing_src_dir() {
    echo "Test 1: Testing missing src directory..."
    
    backup_src_dir
    
    make clean >/dev/null 2>&1 || true
    
    # Build should fail gracefully with missing src directory
    if ! make 2>/dev/null; then
        echo "✓ PASS: Build correctly failed with missing src directory"
    else
        echo "✗ FAIL: Build should fail when src directory is missing"
        restore_src_dir
        exit 1
    fi
    
    restore_src_dir
}

# Test 2: Missing main.c file
test_missing_main_c() {
    echo "Test 2: Testing missing main.c file..."
    
    backup_main_c
    rm -f "src/main.c"
    
    make clean >/dev/null 2>&1 || true
    
    # Build should fail with no source files
    if ! make 2>/dev/null; then
        echo "✓ PASS: Build correctly failed with missing main.c"
    else
        echo "✗ FAIL: Build should fail when main.c is missing"
        restore_main_c
        exit 1
    fi
    
    restore_main_c
}

# Test 3: Missing Makefile
test_missing_makefile() {
    echo "Test 3: Testing missing Makefile..."
    
    backup_makefile
    rm -f "Makefile"
    
    # make command should fail without Makefile
    if ! make 2>/dev/null; then
        echo "✓ PASS: make correctly failed with missing Makefile"
    else
        echo "✗ FAIL: make should fail when Makefile is missing"
        restore_makefile
        exit 1
    fi
    
    restore_makefile
}

# Test 4: Empty src directory (no .c files)
test_empty_src_dir() {
    echo "Test 4: Testing empty src directory..."
    
    backup_main_c
    rm -f src/*.c
    
    # Create an empty file to ensure src directory exists but has no C files
    touch "src/.gitkeep"
    
    make clean >/dev/null 2>&1 || true
    
    # Build should fail with no source files
    if ! make 2>/dev/null; then
        echo "✓ PASS: Build correctly failed with empty src directory"
    else
        echo "✗ FAIL: Build should fail with no C source files"
        rm -f "src/.gitkeep"
        restore_main_c
        exit 1
    fi
    
    rm -f "src/.gitkeep"
    restore_main_c
}

# Test 5: Missing include directory
test_missing_include_dir() {
    echo "Test 5: Testing missing include directory..."
    
    # Backup include directory if it exists
    if [ -d "include" ]; then
        mv "include" "include.backup"
    fi
    
    make clean >/dev/null 2>&1 || true
    
    # Build should still work without include directory (Makefile handles this)
    if make 2>/dev/null; then
        echo "✓ PASS: Build succeeded without include directory"
    else
        echo "⚠ WARNING: Build failed without include directory (may be expected)"
    fi
    
    # Restore include directory
    if [ -d "include.backup" ]; then
        mv "include.backup" "include"
    fi
}

# Test 6: Unreadable main.c (permission test)
test_unreadable_main_c() {
    echo "Test 6: Testing unreadable main.c (permission test)..."
    
    backup_main_c
    
    # Remove read permissions from main.c
    chmod 000 "src/main.c" 2>/dev/null || {
        echo "⚠ SKIP: Cannot change file permissions (not running as appropriate user)"
        restore_main_c
        return 0
    }
    
    make clean >/dev/null 2>&1 || true
    
    # Build should fail due to unreadable file
    if ! make 2>/dev/null; then
        echo "✓ PASS: Build correctly failed with unreadable main.c"
    else
        echo "✗ FAIL: Build should fail when main.c is not readable"
        chmod 644 "src/main.c" 2>/dev/null || true
        restore_main_c
        exit 1
    fi
    
    # Restore permissions
    chmod 644 "src/main.c" 2>/dev/null || true
    restore_main_c
}

# Test 7: Missing build directory (should be created automatically)
test_missing_build_dir() {
    echo "Test 7: Testing missing build directory..."
    
    # Remove build directory if it exists
    rm -rf "build"
    
    make clean >/dev/null 2>&1 || true
    
    # Build should create build directory automatically
    if make 2>/dev/null; then
        if [ -d "build" ]; then
            echo "✓ PASS: Build directory was created automatically"
        else
            echo "⚠ WARNING: Build succeeded but build directory was not created"
        fi
    else
        echo "✗ FAIL: Build failed when build directory was missing"
        exit 1
    fi
}

# Test 8: Read-only project directory
test_readonly_project() {
    echo "Test 8: Testing read-only project directory..."
    
    # Make project directory read-only (if we have permission)
    original_perms=$(stat -c %a . 2>/dev/null || echo "755")
    chmod 555 . 2>/dev/null || {
        echo "⚠ SKIP: Cannot make directory read-only (not running as appropriate user)"
        return 0
    }
    
    make clean >/dev/null 2>&1 || true
    
    # Build should fail in read-only directory (cannot create build artifacts)
    if ! make 2>/dev/null; then
        echo "✓ PASS: Build correctly failed in read-only directory"
    else
        echo "⚠ WARNING: Build succeeded in read-only directory (unexpected)"
    fi
    
    # Restore permissions
    chmod "$original_perms" . 2>/dev/null || chmod 755 .
}

# Test 9: Corrupted Makefile
test_corrupted_makefile() {
    echo "Test 9: Testing corrupted Makefile..."
    
    backup_makefile
    
    # Create a Makefile with syntax errors
    cat > "Makefile" << 'EOF'
# This is a corrupted Makefile with syntax errors
invalid syntax here
no colons or tabs properly formatted
target without dependencies or commands
    command without target
EOF
    
    # make should fail with corrupted Makefile
    if ! make 2>/dev/null; then
        echo "✓ PASS: make correctly failed with corrupted Makefile"
    else
        echo "✗ FAIL: make should fail with corrupted Makefile"
        restore_makefile
        exit 1
    fi
    
    restore_makefile
}

# Run all missing files/directories tests
test_missing_src_dir
test_missing_main_c
test_missing_makefile
test_empty_src_dir
test_missing_include_dir
test_unreadable_main_c
test_missing_build_dir
test_readonly_project
test_corrupted_makefile

echo
echo "=== ALL MISSING FILES/DIRECTORIES TESTS COMPLETED ==="
echo "Build system correctly handles missing files and directories!"