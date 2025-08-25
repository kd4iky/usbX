#!/bin/bash

# TDD Test Script for usbX Makefile - Dependency Failure Edge Cases
# Tests how the build system handles missing dependencies and pkg-config failures

set -e

# Change to project root directory
cd "$(dirname "$0")/.."

echo "=== TDD Dependency Failure Tests for usbX ==="
echo

# Test 1: Missing libusb-1.0 dependency
test_missing_libusb() {
    echo "Test 1: Testing missing libusb-1.0 dependency..."
    
    # Create a temporary pkg-config script that fails for libusb-1.0
    local temp_dir="/tmp/usbx_test_$$"
    mkdir -p "$temp_dir"
    
    # Create fake pkg-config that fails for libusb-1.0
    cat > "$temp_dir/pkg-config" << 'EOF'
#!/bin/bash
if [[ "$*" == *"libusb-1.0"* ]]; then
    echo "Package libusb-1.0 was not found" >&2
    exit 1
fi
# Pass through other dependencies
exec /usr/bin/pkg-config "$@"
EOF
    chmod +x "$temp_dir/pkg-config"
    
    # Test with modified PATH
    (
        export PATH="$temp_dir:$PATH"
        make clean >/dev/null 2>&1 || true
        
        # Should still build but in minimal mode
        if make check-deps 2>&1 | grep -q "Dependencies not found"; then
            echo "✓ PASS: Correctly detected missing libusb-1.0"
        else
            echo "✗ FAIL: Did not detect missing libusb-1.0"
            rm -rf "$temp_dir"
            exit 1
        fi
        
        # Build should still succeed in minimal mode
        if make; then
            echo "✓ PASS: Build succeeded in minimal mode"
        else
            echo "✗ FAIL: Build failed even in minimal mode"
            rm -rf "$temp_dir"
            exit 1
        fi
    )
    
    rm -rf "$temp_dir"
}

# Test 2: All dependencies missing (pkg-config failure)
test_all_deps_missing() {
    echo "Test 2: Testing all dependencies missing..."
    
    local temp_dir="/tmp/usbx_test_$$"
    mkdir -p "$temp_dir"
    
    # Create fake pkg-config that always fails
    cat > "$temp_dir/pkg-config" << 'EOF'
#!/bin/bash
echo "No package found" >&2
exit 1
EOF
    chmod +x "$temp_dir/pkg-config"
    
    (
        export PATH="$temp_dir:$PATH"
        make clean >/dev/null 2>&1 || true
        
        # Should detect missing dependencies but still build
        if make check-deps 2>&1 | grep -q "Dependencies not found"; then
            echo "✓ PASS: Correctly detected all missing dependencies"
        else
            echo "✗ FAIL: Did not detect missing dependencies"
            rm -rf "$temp_dir"
            exit 1
        fi
        
        # Build should succeed in minimal mode
        if make; then
            echo "✓ PASS: Minimal build succeeded without any dependencies"
        else
            echo "✗ FAIL: Minimal build failed"
            rm -rf "$temp_dir"
            exit 1
        fi
    )
    
    rm -rf "$temp_dir"
}

# Test 3: Malformed pkg-config output
test_malformed_pkg_config() {
    echo "Test 3: Testing malformed pkg-config output..."
    
    local temp_dir="/tmp/usbx_test_$$"
    mkdir -p "$temp_dir"
    
    # Create fake pkg-config that returns malformed output
    cat > "$temp_dir/pkg-config" << 'EOF'
#!/bin/bash
if [[ "$*" == *"--cflags"* ]]; then
    echo "MALFORMED_FLAGS_@#$%"
    exit 0
elif [[ "$*" == *"--libs"* ]]; then
    echo "MALFORMED_LIBS_!@#"
    exit 0
elif [[ "$*" == *"--exists"* ]]; then
    exit 0  # Pretend dependencies exist
fi
exec /usr/bin/pkg-config "$@"
EOF
    chmod +x "$temp_dir/pkg-config"
    
    (
        export PATH="$temp_dir:$PATH"
        make clean >/dev/null 2>&1 || true
        
        # Build might fail with malformed flags, which is expected
        if ! make 2>/dev/null; then
            echo "✓ PASS: Build correctly failed with malformed pkg-config output"
        else
            echo "⚠ WARNING: Build succeeded despite malformed pkg-config (might be resilient)"
        fi
    )
    
    rm -rf "$temp_dir"
}

# Test 4: Partial dependency availability
test_partial_deps() {
    echo "Test 4: Testing partial dependency availability..."
    
    local temp_dir="/tmp/usbx_test_$$"
    mkdir -p "$temp_dir"
    
    # Create fake pkg-config that only has some dependencies
    cat > "$temp_dir/pkg-config" << 'EOF'
#!/bin/bash
if [[ "$*" == *"json-c"* ]]; then
    echo "Package json-c was not found" >&2
    exit 1
fi
# Pass through other dependencies
exec /usr/bin/pkg-config "$@"
EOF
    chmod +x "$temp_dir/pkg-config"
    
    (
        export PATH="$temp_dir:$PATH"
        make clean >/dev/null 2>&1 || true
        
        # Should fallback to minimal build when any dependency is missing
        if make check-deps 2>&1 | grep -q "Dependencies not found"; then
            echo "✓ PASS: Correctly detected partial dependency failure"
        else
            echo "✗ FAIL: Did not handle partial dependency failure"
            rm -rf "$temp_dir"
            exit 1
        fi
    )
    
    rm -rf "$temp_dir"
}

# Run all dependency tests
test_missing_libusb
test_all_deps_missing
test_malformed_pkg_config
test_partial_deps

echo
echo "=== ALL DEPENDENCY TESTS PASSED ==="
echo "Build system correctly handles dependency failures!"