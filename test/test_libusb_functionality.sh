#!/bin/bash

# Test script for libusb functionality in usbX
# This test verifies that libusb can enumerate USB devices

set -e

# Change to project root directory
cd "$(dirname "$0")/.."

echo "=== libusb Functionality Test ==="
echo

# Create a simple test program that uses more libusb functions
cat > /tmp/libusb_functionality_test.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <libusb-1.0/libusb.h>

int main(void) {
    libusb_context *ctx = NULL;
    int result;
    
    // Initialize libusb
    result = libusb_init(&ctx);
    if (result < 0) {
        fprintf(stderr, "Failed to initialize libusb: %s\n", libusb_error_name(result));
        return 1;
    }
    
    printf("libusb initialized successfully\n");
    
    // Get device list
    libusb_device **devs;
    ssize_t cnt = libusb_get_device_list(ctx, &devs);
    if (cnt < 0) {
        fprintf(stderr, "Failed to get device list: %s\n", libusb_error_name(cnt));
        libusb_exit(ctx);
        return 1;
    }
    
    printf("Found %zd USB devices\n", cnt);
    
    // Clean up
    libusb_free_device_list(devs, 1);
    libusb_exit(ctx);
    
    printf("libusb functionality test completed successfully\n");
    return 0;
}
EOF

echo "Test 1: Compiling libusb functionality test..."
if ! gcc -std=c99 -Wall -Wextra -I/usr/include/libusb-1.0 /tmp/libusb_functionality_test.c -o /tmp/libusb_functionality_test -lusb-1.0; then
    echo "FAIL: Could not compile libusb functionality test"
    exit 1
fi
echo "PASS: libusb functionality test compiled successfully"

echo "Test 2: Running libusb functionality test..."
if ! /tmp/libusb_functionality_test; then
    echo "FAIL: libusb functionality test failed"
    exit 1
fi
echo "PASS: libusb functionality test executed successfully"

echo "Test 3: Testing libusb version information..."
cat > /tmp/libusb_version_test.c << 'EOF'
#include <stdio.h>
#include <libusb-1.0/libusb.h>

int main(void) {
    const struct libusb_version* version = libusb_get_version();
    printf("libusb version: %d.%d.%d.%d%s\n", 
           version->major, version->minor, version->micro, version->nano,
           version->rc ? version->rc : "");
    return 0;
}
EOF

if ! gcc -std=c99 -Wall -Wextra -I/usr/include/libusb-1.0 /tmp/libusb_version_test.c -o /tmp/libusb_version_test -lusb-1.0; then
    echo "FAIL: Could not compile version test"
    exit 1
fi

if ! /tmp/libusb_version_test; then
    echo "FAIL: Version test failed"
    exit 1
fi
echo "PASS: libusb version information retrieved successfully"

echo "Test 4: Cleanup test files..."
rm -f /tmp/libusb_functionality_test.c /tmp/libusb_functionality_test
rm -f /tmp/libusb_version_test.c /tmp/libusb_version_test
echo "PASS: Cleanup completed"

echo
echo "=== ALL LIBUSB FUNCTIONALITY TESTS PASSED ==="
echo "libusb is fully integrated and functional!"