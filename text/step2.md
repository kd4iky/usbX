### Project Structure and Initialization

This step provides a solid foundation but can be expanded for clarity, including exact file contents, best practices for organization, handling additional files like uthash.h (from the setup step), and initial code snippets to kickstart development. This ensures the project is modular, easy to build, and follows standard C project conventions. Here's the expanded version:

- **Organize the Project Directory Structure**:
  - Navigate into the cloned repository: `cd usbX`.
  - Create a source directory for code files: `mkdir src`. This keeps source files separate from build artifacts or docs.
  - Optionally, create an include directory for headers: `mkdir include`. This is useful if you plan to separate headers, but for simplicity, you can place everything in `src/` initially.
  - Create the main source file: `touch src/main.c`. This will be the entry point for the microservice.
  - Place the downloaded `uthash.h` (from the setup step) into `src/` or `include/`: For example, `mv uthash.h src/`. This header-only library will be used for the hash map in state management.
  - Add other supporting files as needed: For example, `touch src/handlers.c` for separating request handler logic, or `touch src/utils.c` for helper functions like base64 encoding/decoding. Start simple with just `main.c` and expand later.

- **Create a Makefile for Building and Managing the Project**:
  - Create the Makefile: `touch Makefile`.
  - Edit it to include build rules, compilation flags, and cleaning targets. Use a text editor (e.g., nano or vim) to add the following content for a basic setup:
    ```
    CC = gcc
    CFLAGS = -Wall -Wextra -O2 $(shell pkg-config --cflags libusb-1.0 libmicrohttpd json-c)
    LDFLAGS = $(shell pkg-config --libs libusb-1.0 libmicrohttpd json-c) -lpthread

    SRC = src/main.c  # Add more files here as you expand, e.g., src/handlers.c
    OBJ = $(SRC:.c=.o)
    TARGET = usbx

    all: $(TARGET)

    $(TARGET): $(OBJ)
    	$(CC) $(OBJ) -o $@ $(LDFLAGS)

    %.o: %.c
    	$(CC) $(CFLAGS) -c $< -o $@

    clean:
    	rm -f $(OBJ) $(TARGET)

    run: $(TARGET)
    	./$(TARGET)
    ```
    - Explanation:
      - `CFLAGS`: Enables warnings (`-Wall -Wextra`), optimization (`-O2`), and uses `pkg-config` to automatically include library flags (handles include paths and definitions).
      - `LDFLAGS`: Links the required libraries (`-lusb-1.0 -lmicrohttpd -ljson-c`) and pthread for threading.
      - Targets: `all` builds the executable; `clean` removes build files; `run` builds and executes for quick testing.
      - This is more robust than a single `gcc` command, as it supports multiple files and recompilation.
    - Test the Makefile: Run `make` to compile (it will fail initially since `main.c` is empty, but this verifies setup). Later, use `make clean` to reset.

- **Set Up Basic Includes and Global Declarations in main.c**:
  - Open `src/main.c` in a text editor and add the necessary header includes at the top:
    ```c
    #include <stdio.h>      // For printf/fprintf
    #include <stdlib.h>     // For exit/malloc
    #include <string.h>     // For string operations
    #include <pthread.h>    // For threading and mutex
    #include <microhttpd.h> // For HTTP server
    #include <json-c/json.h> // For JSON handling (note: some distros use <json/json.h>)
    #include <libusb-1.0/libusb.h> // For libusb
    #include "uthash.h"     // For hash map (assuming it's in src/; use <uthash.h> if in include/)
    ```
    - Add global declarations just after the includes:
      ```c
      #define PORT 8080       // Default HTTP port; make configurable later

      libusb_context *ctx = NULL; // Global libusb context
      struct HandleEntry *handles = NULL; // Hash map for open USB handles
      pthread_mutex_t handles_mutex = PTHREAD_MUTEX_INITIALIZER; // Mutex for thread safety
      int next_handle_id = 1; // Counter for unique handle IDs
      pthread_t event_thread; // Thread for libusb event handling
      ```
    - Define the `HandleEntry` struct for the hash map (using uthash):
      ```c
      struct HandleEntry {
          int id;                    // Unique ID
          libusb_device_handle *handle; // Libusb handle
          UT_hash_handle hh;         // Uthash handle (required for hashing)
      };
      ```

- **Initialize libusb in the main Function**:
  - In `main.c`, add the `main` function skeleton with libusb initialization:
    ```c
    int main() {
        int ret;

        // Initialize libusb context
        ret = libusb_init(&ctx);
        if (ret < 0) {
            fprintf(stderr, "Failed to initialize libusb: %s\n", libusb_error_name(ret));
            return EXIT_FAILURE;
        }

        // Rest of the code will go here: start event thread, HTTP daemon, etc.

        // Cleanup on exit (add more as project grows)
        libusb_exit(ctx);
        return EXIT_SUCCESS;
    }
    ```
    - Explanation: 
      - `libusb_init(&ctx)` creates the context for all USB operations. Error checking uses `libusb_error_name` for human-readable messages.
      - Use `EXIT_FAILURE`/`EXIT_SUCCESS` from stdlib.h for standard return values.
      - This is placed early in `main` as libusb must be initialized before any USB calls.
      - Later steps will add the HTTP server startup and event thread here.

- **Additional Best Practices for Initialization**:
  - Create a `.gitignore` file to avoid committing build artifacts: `touch .gitignore` and add lines like:
    ```
    *.o
    usbx
    ```
    - This prevents object files and the executable from being pushed to GitHub.
  - Commit initial changes: Run `git add .`, `git commit -m "Initial project structure and libusb setup"`, and `git push origin main` to sync with GitHub.
  - Verify compilation early: Even with minimal code, run `make` to check for header/include issues (e.g., if pkg-config fails, ensure libraries are installed correctly).
  - Troubleshooting: If includes fail (e.g., "No such file or directory"), verify paths with `pkg-config --cflags libusb-1.0` or adjust Makefile. For uthash, ensure it's in the same directory or update the include path with `-Iinclude`.

This expansion makes the step more actionable with code examples, full Makefile, and integration of prior elements like uthash, while keeping it beginner-friendly. If you need further details (e.g., full initial main.c file), let me know!
