#!/bin/bash

# TDD Test Script for uthash Integration in usbX
# This test verifies that uthash.h is properly integrated and compiles

set -e

# Change to project root directory
cd "$(dirname "$0")/.."

echo "=== TDD uthash Integration Test ==="
echo

# Test 1: Check if uthash.h exists in src/
echo "Test 1: Checking if src/uthash.h exists..."
if [ ! -f "src/uthash.h" ]; then
    echo "FAIL: src/uthash.h not found"
    exit 1
fi
echo "PASS: src/uthash.h found"

# Test 2: Check if main.c includes uthash
echo "Test 2: Checking if main.c includes uthash..."
if ! grep -q '#include.*uthash' src/main.c; then
    echo "FAIL: main.c does not include uthash"
    exit 1
fi
echo "PASS: main.c includes uthash"

# Test 3: Test compilation with uthash include
echo "Test 3: Testing compilation with uthash include..."
if ! gcc -std=c99 -Wall -Wextra -I./include -I./src -c src/main.c -o /tmp/test_uthash.o 2>/dev/null; then
    echo "FAIL: Compilation failed with uthash include"
    exit 1
fi
echo "PASS: Compilation succeeded with uthash"

# Test 4: Test that uthash macros are available
echo "Test 4: Testing uthash functionality..."
cat > /tmp/test_uthash_functionality.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "uthash.h"

struct test_entry {
    int id;
    char name[20];
    UT_hash_handle hh;
};

int main() {
    struct test_entry *hash = NULL;
    struct test_entry *entry = malloc(sizeof(struct test_entry));
    entry->id = 1;
    strcpy(entry->name, "test");
    
    HASH_ADD_INT(hash, id, entry);
    
    struct test_entry *found;
    HASH_FIND_INT(hash, &entry->id, found);
    
    if (found && strcmp(found->name, "test") == 0) {
        printf("uthash functionality verified\n");
        return 0;
    }
    
    return 1;
}
EOF

if ! gcc -std=c99 -Wall -Wextra -I./include -I./src /tmp/test_uthash_functionality.c -o /tmp/test_uthash_functionality 2>/dev/null; then
    echo "FAIL: uthash functionality test compilation failed"
    exit 1
fi

if ! /tmp/test_uthash_functionality; then
    echo "FAIL: uthash functionality test execution failed"
    exit 1
fi
echo "PASS: uthash functionality verified"

# Test 5: Clean up test files
echo "Test 5: Cleaning up test files..."
rm -f /tmp/test_uthash.o /tmp/test_uthash_functionality.c /tmp/test_uthash_functionality
echo "PASS: Cleanup completed"

echo
echo "=== ALL UTHASH TESTS PASSED ==="
echo "uthash integration is working correctly!"