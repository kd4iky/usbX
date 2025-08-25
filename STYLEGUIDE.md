# Coding Style Guide

Consistency makes the code easier to read, maintain, and contribute to.  
Please follow these guidelines when contributing.

---

## General Principles
- Write clean, readable, and well-documented code.  
- Keep functions short and focused (prefer < 50 lines).  
- Prefer clarity over cleverness.
- Follow Test-Driven Development (TDD) practices.
- Handle errors gracefully with meaningful messages.

---

## C Coding Conventions

### Code Style
- **Indentation**: 4 spaces, no tabs.  
- **Line Length**: Maximum 100 characters per line.
- **Braces**: K&R style  
  ```c
  if (condition) {
      do_something();
  } else {
      do_something_else();
  }
  ```

### Naming Conventions
- **Variables & Functions**: `snake_case`
  ```c
  int device_count = 0;
  libusb_context *usb_context = NULL;
  void init_device_manager(void);
  ```
- **Constants & Macros**: `UPPER_CASE`
  ```c
  #define MAX_DEVICES 256
  #define DEFAULT_PORT 8080
  ```
- **Struct Names**: `snake_case` 
  ```c
  struct device_handle {
      int handle_id;
      libusb_device_handle *usb_handle;
      UT_hash_handle hh;
  };
  ```

### Comments
- **Multi-line**: Use `/* ... */` for explanations
  ```c
  /* 
   * Initialize libusb context and set up error handling.
   * Returns 0 on success, negative error code on failure.
   */
  ```
- **Inline**: Use `//` for short notes
  ```c
  int result = libusb_init(&ctx);  // Initialize USB context
  ```
- **Function Documentation**: Document public functions
  ```c
  /*
   * Opens a USB device by bus and address
   * @param bus: USB bus number
   * @param address: Device address on the bus  
   * @return: Handle ID on success, -1 on error
   */
  int open_device_by_address(int bus, int address);
  ```

### Header Guards
```c
#ifndef USBX_DEVICE_H
#define USBX_DEVICE_H

// Code here

#endif // USBX_DEVICE_H
```

### Error Handling
- **Always check return values** from libusb functions
- **Use descriptive error messages** with `libusb_error_name()`
- **Return proper exit codes**: `EXIT_SUCCESS` / `EXIT_FAILURE`
  ```c
  int result = libusb_init(&ctx);
  if (result < 0) {
      fprintf(stderr, "Error: Failed to initialize libusb: %s (code: %d)\n", 
              libusb_error_name(result), result);
      return EXIT_FAILURE;
  }
  ```

### Memory Management
- **Always free** allocated memory
- **Set pointers to NULL** after freeing
- **Use proper cleanup** in error paths
  ```c
  struct device_handle *handle = malloc(sizeof(struct device_handle));
  if (!handle) {
      return -1;  // Handle allocation failure
  }
  
  // ... use handle ...
  
  free(handle);
  handle = NULL;
  ```

### USB-Specific Guidelines

#### Device Handle Management
```c
// Use uthash for device handle storage
struct device_handle {
    int handle_id;                    // Unique identifier
    libusb_device_handle *usb_handle; // libusb handle  
    UT_hash_handle hh;                // Hash table handle
};

// Always check handle validity
struct device_handle *find_device_handle(int handle_id) {
    struct device_handle *handle = NULL;
    HASH_FIND_INT(device_handles, &handle_id, handle);
    return handle;  // Returns NULL if not found
}
```

#### USB Transfer Operations
```c
// Always set timeouts for transfers
int result = libusb_bulk_transfer(
    device_handle,
    endpoint,
    buffer,
    length,
    &transferred,
    1000  // 1 second timeout
);
```

### Project-Specific Patterns

#### Global Variables
- **Minimize global variables**
- **Use descriptive names** for necessary globals
- **Initialize explicitly**
  ```c
  // Global libusb context (initialized in main)
  libusb_context *global_usb_context = NULL;
  
  // Device handle hash table
  struct device_handle *device_handles = NULL;
  ```

#### Function Organization
```c
// Order functions logically:
// 1. Helper/utility functions first
// 2. Core functionality  
// 3. Main function last

// Example structure:
static void cleanup_resources(void);           // Utility
static int init_device_manager(void);          // Core
int main(void);                                // Entry point
```

---

## Commit Messages

Follow conventional commit format:

- **feat**: New feature (`feat: add device enumeration endpoint`)
- **fix**: Bug fix (`fix: memory leak in device cleanup`)  
- **test**: Add/update tests (`test: add libusb functionality tests`)
- **docs**: Documentation (`docs: update API documentation`)
- **refactor**: Code refactoring (`refactor: simplify error handling`)

**Format**: 
```
type: short description

Optional longer explanation of what this commit does and why.

Fixes #123
```

**Examples**:
```
feat: implement HTTP server with libmicrohttpd

- Add HTTP server initialization in main.c
- Create basic /health endpoint
- Add server startup/shutdown handling

Closes #45

fix: prevent memory leak in device handle cleanup

HASH_DEL was not being called before free(), causing
uthash to maintain stale pointers.

Fixes #67
```

---

## Testing Guidelines

### TDD Requirements
- **Write tests first** before implementing features
- **All tests must pass** before submitting PR: `make test`
- **Add regression tests** for bug fixes
- **Test both success and error paths**

### Test Categories
1. **Build Tests** (`test_build.sh`): Makefile, compilation, linking
2. **Integration Tests** (`test_uthash.sh`): Component integration  
3. **Unit Tests** (`test_libusb_init.sh`): Individual function testing
4. **Functionality Tests** (`test_libusb_functionality.sh`): End-to-end testing

### Test Naming
```bash
# Test files: descriptive names with .sh extension
test_http_server.sh         # HTTP server functionality
test_device_management.sh   # Device handle operations  
test_json_parsing.sh        # JSON request/response handling
```

### Test Structure
```bash
#!/bin/bash
set -e

cd "$(dirname "$0")/.."  # Change to project root

echo "=== Test Description ==="

# Test 1: Setup/prerequisites
echo "Test 1: Description..."
# test commands
echo "PASS: Test 1 completed"

# Test 2: Main functionality  
echo "Test 2: Description..."
# test commands
echo "PASS: Test 2 completed"

# Cleanup
echo "Cleanup: Removing test artifacts..."
# cleanup commands

echo "=== ALL TESTS PASSED ==="
```

---

## File Organization

### Directory Structure
```
usbX/
├── src/                    # Source code
│   ├── main.c             # Main executable
│   └── *.c                # Additional modules
├── include/               # Header files  
│   ├── uthash.h          # External headers
│   └── usbx_*.h          # Project headers
├── test/                  # Test suite
│   ├── test_*.sh         # Test scripts
│   └── run_all_tests.sh  # Test runner
├── *.md                   # Documentation
└── Makefile               # Build system
```

### Header File Guidelines
- **Public APIs**: Place in `include/`
- **Private headers**: Keep in `src/` if needed
- **External libraries**: Place in `include/`
- **Use include guards** consistently

---

## Code Review Checklist

Before submitting code, verify:

- [ ] **Follows style guide**: Indentation, naming, comments
- [ ] **Tests pass**: `make test` returns success
- [ ] **Error handling**: All failure paths handled
- [ ] **Memory management**: No leaks, proper cleanup
- [ ] **Documentation**: Functions documented, README updated
- [ ] **USB patterns**: Uses libusb best practices
- [ ] **Thread safety**: Consider concurrent access if applicable
