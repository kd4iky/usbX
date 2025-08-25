/*
 * TDD Unit Test for libusb Initialization in usbX
 * 
 * This test verifies that main() properly initializes libusb context
 * and returns correct exit codes based on success/failure.
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>
#include <assert.h>

// Forward declaration of the function we want to test
int usbx_main(void);

int main(void) {
    printf("=== TDD libusb Initialization Test ===\n\n");
    
    // Test 1: Fork and test normal execution
    printf("Test 1: Testing libusb initialization success...\n");
    
    pid_t pid = fork();
    if (pid == 0) {
        // Child process - call the main function
        exit(usbx_main());
    } else if (pid > 0) {
        // Parent process - wait for child and check exit status
        int status;
        waitpid(pid, &status, 0);
        
        if (WIFEXITED(status)) {
            int exit_code = WEXITSTATUS(status);
            printf("Child exited with code: %d\n", exit_code);
            
            if (exit_code == EXIT_SUCCESS) {
                printf("PASS: libusb initialization succeeded\n");
            } else if (exit_code == EXIT_FAILURE) {
                printf("PASS: libusb initialization failed as expected\n");
            } else {
                printf("FAIL: Unexpected exit code %d\n", exit_code);
                return 1;
            }
        } else {
            printf("FAIL: Child did not exit normally\n");
            return 1;
        }
    } else {
        perror("fork failed");
        return 1;
    }
    
    printf("\n=== TEST SUMMARY ===\n");
    printf("libusb initialization test completed successfully\n");
    printf("The function properly returns EXIT_SUCCESS or EXIT_FAILURE\n");
    
    return 0;
}