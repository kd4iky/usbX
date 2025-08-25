/*
 * TDD Test for add_handle Function
 * 
 * This test file implements Test-Driven Development for the add_handle function.
 * The test follows the RED-GREEN-REFACTOR cycle:
 * 1. RED: Write a failing test
 * 2. GREEN: Write minimal code to pass
 * 3. REFACTOR: Improve code quality
 */

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <assert.h>
#include <libusb-1.0/libusb.h>
#include "uthash.h"

// Forward declaration of the function we're testing
int add_handle(libusb_device_handle *device_handle);

// HandleEntry struct (copied from main_handle_refactored.c)
typedef struct HandleEntry {
    int handle_id;
    libusb_device_handle *device_handle;
    UT_hash_handle hh;
} HandleEntry;

// External declarations of globals (will be defined in the implementation)
extern HandleEntry *handles;
extern pthread_mutex_t handles_mutex;
extern int next_handle_id;

/**
 * Test 1: add_handle with NULL handle should return valid ID
 * 
 * This is the smallest testable unit - the function should:
 * - Accept a NULL libusb_device_handle pointer
 * - Return a positive integer ID (>= 1)
 * - Thread-safe operation using mutex
 */
void test_add_handle_with_null() {
    printf("TEST: add_handle with NULL handle\n");
    
    // Call add_handle with NULL (this should fail initially)
    int handle_id = add_handle(NULL);
    
    // Assert we get a valid ID (>= 1)
    assert(handle_id >= 1);
    
    printf("✓ add_handle returned ID: %d\n", handle_id);
}

/**
 * Test 2: add_handle should return unique IDs for multiple calls
 */
void test_add_handle_unique_ids() {
    printf("TEST: add_handle returns unique IDs\n");
    
    int id1 = add_handle(NULL);
    int id2 = add_handle(NULL);
    
    // IDs should be different
    assert(id1 != id2);
    assert(id1 >= 1);
    assert(id2 >= 1);
    
    printf("✓ Unique IDs: %d, %d\n", id1, id2);
}

int main(void) {
    printf("=== TDD Tests for add_handle Function ===\n\n");
    
    // Run tests
    test_add_handle_with_null();
    test_add_handle_unique_ids();
    
    printf("\n✓ All tests passed!\n");
    return EXIT_SUCCESS;
}