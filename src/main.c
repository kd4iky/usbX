/**
 * @file main.c
 * @brief usbX microservice - libusb-based USB device management service
 * @author usbX Development Team
 * @version 0.2.0
 * @date 2025-08-25
 * 
 * This file contains the main implementation of the usbX microservice,
 * providing USB device access through libusb-1.0 with hash table-based
 * device handle management using uthash.
 * 
 * Current implementation includes:
 * - libusb context initialization and cleanup
 * - uthash integration for device handle storage
 * - Comprehensive error handling with descriptive messages
 * 
 * @copyright GNU General Public License v3.0
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Include uthash - will work from either include/ or src/
#ifdef __has_include
    #if __has_include("uthash.h")
        #include "uthash.h"
    #else
        #error "uthash.h not found. Run ./download_uthash.sh to install it."
    #endif
#else
    // Fallback for older compilers
    #include "uthash.h"
#endif

#ifdef USE_DEPS
#include <libusb-1.0/libusb.h>
#endif

/**
 * @struct device_handle
 * @brief Structure for managing USB device handles with hash table storage
 * 
 * This structure is used with uthash to provide efficient storage and
 * lookup of USB device handles by integer ID.
 */
struct device_handle {
    int handle_id;           /**< Unique device handle identifier */
    void *device_ptr;        /**< Pointer to libusb device handle (placeholder) */
    UT_hash_handle hh;       /**< uthash handle - makes structure hashable */
};

/** @brief Global libusb context for USB operations */
#ifdef USE_DEPS
libusb_context *ctx = NULL;
#endif

/**
 * @brief Main entry point for the usbX microservice
 * 
 * Initializes the usbX microservice by setting up uthash functionality
 * and initializing libusb context for USB device operations.
 * 
 * Current implementation demonstrates:
 * - uthash hash table operations with device handles
 * - libusb context initialization with error handling
 * - Proper resource cleanup and exit code handling
 * 
 * @return EXIT_SUCCESS on successful initialization, EXIT_FAILURE on error
 * 
 * @note This is the current foundation implementation. Future versions will
 *       include HTTP server initialization and RESTful API endpoints.
 */
int main(void) {
    printf("usbX microservice starting...\n");
    
    // Demonstrate uthash functionality
    printf("Testing uthash integration...\n");
    struct device_handle *handles = NULL;
    
    // Create a test handle
    struct device_handle *handle = malloc(sizeof(struct device_handle));
    handle->handle_id = 1;
    handle->device_ptr = (void*)0xDEADBEEF; // Dummy pointer
    
    // Add to hash table
    HASH_ADD_INT(handles, handle_id, handle);
    
    // Find in hash table
    struct device_handle *found_handle;
    HASH_FIND_INT(handles, &handle->handle_id, found_handle);
    
    if (found_handle) {
        printf("✓ uthash working: Found handle with ID %d\n", found_handle->handle_id);
    } else {
        printf("✗ uthash test failed\n");
    }
    
    // Clean up uthash
    HASH_DEL(handles, handle);
    free(handle);
    
    // TDD libusb initialization with proper error handling
#ifdef USE_DEPS
    printf("Initializing libusb...\n");
    int result = libusb_init(&ctx);
    
    if (result < 0) {
        // Log error to stderr with specific error information
        fprintf(stderr, "Error: Failed to initialize libusb: %s (code: %d)\n", 
                libusb_error_name(result), result);
        return EXIT_FAILURE;
    }
    
    printf("✓ libusb initialized successfully\n");
    printf("usbX service ready!\n");
    
    // Cleanup and exit with success
    libusb_exit(ctx);
#else
    printf("✓ Minimal build mode - libusb functionality not available\n");
    printf("usbX service ready! (minimal mode)\n");
#endif
    return EXIT_SUCCESS;
}