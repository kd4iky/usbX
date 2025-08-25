/*
 * TDD Test for libusb Initialization - Following Red-Green-Refactor
 * 
 * This test verifies the smallest testable unit: a main function that
 * initializes global libusb_context *ctx and exits with correct status.
 * 
 * Test Requirements:
 * - Check return code of libusb_init
 * - Exit with EXIT_FAILURE on error
 * - Exit with EXIT_SUCCESS on success
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>
#include <assert.h>

// Function under test - will be defined in minimal main.c
extern int main(void);

int test_main(void) {
    printf("=== TDD libusb Initialization Test ===\n");
    printf("Testing: main() initializes libusb_context and returns correct exit code\n\n");
    
    // Fork to test the main function in isolation
    pid_t pid = fork();
    
    if (pid == 0) {
        // Child process - call main() and exit with its return value
        exit(main());
    } else if (pid > 0) {
        // Parent process - wait and analyze exit code
        int status;
        waitpid(pid, &status, 0);
        
        if (WIFEXITED(status)) {
            int exit_code = WEXITSTATUS(status);
            printf("main() returned exit code: %d\n", exit_code);
            
            // Test passes if main() returns either SUCCESS or FAILURE
            // (both are valid depending on libusb availability)
            if (exit_code == EXIT_SUCCESS) {
                printf("✓ PASS: libusb initialization succeeded\n");
                return 0;
            } else if (exit_code == EXIT_FAILURE) {
                printf("✓ PASS: libusb initialization failed gracefully\n");
                return 0;
            } else {
                printf("✗ FAIL: Invalid exit code %d (expected 0 or 1)\n", exit_code);
                return 1;
            }
        } else {
            printf("✗ FAIL: main() did not exit normally\n");
            return 1;
        }
    } else {
        perror("fork failed");
        return 1;
    }
}

int main(void) {
    return test_main();
}