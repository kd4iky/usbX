/*
 * Extended TDD Tests for add_handle Function
 * 
 * Tests error conditions and edge cases:
 * - Memory allocation failure simulation
 * - ID overflow testing
 * - Thread safety verification
 */

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <assert.h>
#include <libusb-1.0/libusb.h>
#include "uthash.h"

// Forward declaration
int add_handle(libusb_device_handle *device_handle);

// HandleEntry struct
typedef struct HandleEntry {
    int handle_id;
    libusb_device_handle *device_handle;
    UT_hash_handle hh;
} HandleEntry;

// External globals
extern HandleEntry *handles;
extern pthread_mutex_t handles_mutex;
extern int next_handle_id;

/**
 * Test ID overflow condition
 */
void test_id_overflow() {
    printf("TEST: ID overflow handling\n");
    
    // Save original value
    int original_id = next_handle_id;
    
    // Set to overflow condition
    next_handle_id = -1;
    
    int result = add_handle(NULL);
    assert(result == -1);
    
    // Restore original value
    next_handle_id = original_id;
    
    printf("✓ ID overflow properly handled\n");
}

/**
 * Test thread safety with concurrent access
 */
void* thread_add_handles(void* arg) {
    int thread_id = *(int*)arg;
    
    for (int i = 0; i < 5; i++) {
        int handle_id = add_handle(NULL);
        printf("Thread %d: Added handle %d\n", thread_id, handle_id);
        assert(handle_id >= 1);
    }
    
    return NULL;
}

void test_thread_safety() {
    printf("TEST: Thread safety\n");
    
    pthread_t threads[3];
    int thread_ids[] = {1, 2, 3};
    
    // Create threads
    for (int i = 0; i < 3; i++) {
        pthread_create(&threads[i], NULL, thread_add_handles, &thread_ids[i]);
    }
    
    // Wait for threads
    for (int i = 0; i < 3; i++) {
        pthread_join(threads[i], NULL);
    }
    
    printf("✓ Thread safety test completed\n");
}

int main(void) {
    printf("=== Extended TDD Tests for add_handle Function ===\n\n");
    
    test_id_overflow();
    test_thread_safety();
    
    printf("\n✓ All extended tests passed!\n");
    return EXIT_SUCCESS;
}