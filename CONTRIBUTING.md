# Contributing to usbX

We're excited you're interested in contributing to the usbX microservice! This project follows **Test-Driven Development (TDD)** practices to ensure high code quality and reliability.

---

## How to Contribute

We welcome contributions in these areas:

- **🐛 Bug Reports**: Found an issue? Report it with clear reproduction steps
- **💡 Feature Requests**: Ideas for USB microservice functionality
- **🧪 Testing**: Expand our comprehensive test suite  
- **📚 Documentation**: Improve guides, examples, and API docs
- **🔧 Code**: Implement features, fix bugs, optimize performance
- **🚀 HTTP Server**: Help implement the RESTful API layer
- **🔌 USB Operations**: Extend libusb functionality

---

## Development Setup

### Prerequisites
```bash
# Install dependencies
sudo apt-get install libusb-1.0-0-dev libmicrohttpd-dev libjson-c-dev build-essential pkg-config

# Clone and setup
git clone <your-fork-url>
cd usbX
make check-deps  # Verify dependencies
```

### Test-Driven Development Workflow

**🚨 IMPORTANT**: Always run tests before and after changes!

```bash
# 1. Run existing tests first
make test

# 2. All tests should pass before you start
# Expected: "All tests completed successfully!"

# 3. Write your tests first (TDD approach)
# 4. Implement code to make tests pass
# 5. Verify all tests still pass

make test  # Must pass before submitting PR
```

---

## Before You Start Coding

### 1. **Check Current Status**
```bash
# Verify current implementation works
./usbx
# Should show: "✓ libusb initialized successfully"

# Run comprehensive tests
make test
```

### 2. **Environment Setup**
```bash
# Fork the repository
# Clone your fork
git clone <your-fork-url>
cd usbX

# Create feature branch
git checkout -b feature/your-feature-name
# OR for bug fixes
git checkout -b fix/issue-description
```

### 3. **Understand the Architecture**
- **src/main.c**: Current implementation with libusb + uthash
- **test/**: TDD test suite (4 test categories)
- **THOUGHTS.md**: Detailed architecture design
- **include/uthash.h**: Hash table for device management

---

## Coding Guidelines

### C Code Style (see STYLEGUIDE.md):
- **Indentation**: 4 spaces, no tabs
- **Braces**: K&R style  
- **Variables**: `snake_case`
- **Constants**: `UPPER_CASE`
- **Comments**: `/* multi-line */` and `// inline`

### TDD Requirements:
```bash
# 1. Write failing test first
./test/test_your_feature.sh  # Should fail initially

# 2. Write minimal code to pass test
# Edit src/main.c or create new files

# 3. Verify test passes
./test/test_your_feature.sh  # Should now pass

# 4. Run full test suite
make test  # All tests must pass
```

### Testing Standards:
- **Every new feature** must have tests
- **Every bug fix** must have a test preventing regression  
- **All tests** must pass: `make test`
- **Test files**: Place in `test/` directory with descriptive names

### Error Handling:
```c
// Use libusb error names and exit codes
if (result < 0) {
    fprintf(stderr, "Error: %s (code: %d)\n", 
            libusb_error_name(result), result);
    return EXIT_FAILURE;
}
```

---

## Testing Categories

Add tests to appropriate categories:

1. **test_build.sh**: Build system and Makefile tests
2. **test_uthash.sh**: Hash table integration tests  
3. **test_libusb_init.sh**: libusb initialization tests
4. **test_libusb_functionality.sh**: USB device enumeration tests

### Creating New Tests:
```bash
# Create new test file
touch test/test_your_feature.sh
chmod +x test/test_your_feature.sh

# Add to Makefile test target
# Edit Makefile to include your test in the 'test' target
```

---

## Priority Contribution Areas

### 🔥 High Priority:
- **HTTP Server Integration**: Implement libmicrohttpd-based REST API
- **JSON API Endpoints**: Device enumeration, open/close, transfers
- **Error Handling**: Robust HTTP error responses
- **Device Management**: Expand uthash-based handle storage

### 🚧 Medium Priority: 
- **USB Transfer Operations**: Bulk, control, interrupt transfers
- **Configuration Management**: Config file parsing
- **Performance Testing**: Load testing for concurrent requests
- **Docker Integration**: Container support with USB passthrough

### 🌟 Future Features:
- **Authentication**: API key or token-based auth
- **WebSocket Support**: Real-time USB event notifications  
- **Device Filtering**: Filter by VID/PID, device class
- **Logging**: Structured logging with levels

---

## Submitting a Pull Request

### Pre-Submission Checklist:
```bash
# ✅ All tests pass
make test

# ✅ Code follows style guide
# Check STYLEGUIDE.md compliance

# ✅ New functionality has tests
# Ensure your changes include tests

# ✅ Documentation updated if needed
# Update relevant .md files
```

### PR Requirements:
1. **Clear Title**: `feat: add USB device filtering` or `fix: memory leak in handle cleanup`
2. **Description**: 
   - What the change does
   - Why it's needed  
   - How to test it
   - Reference any issues: `Fixes #123`
3. **Test Evidence**: Show test output in PR description
4. **Breaking Changes**: Clearly mark any API changes

### Example PR Description:
```markdown
## Summary
Implements HTTP server initialization using libmicrohttpd

## Changes
- Added HTTP server startup in main.c
- Created basic /health endpoint  
- Added HTTP server tests

## Testing  
```bash
make test  # All tests pass
curl http://localhost:8080/health  # Returns 200 OK
```

Fixes #45
```

---

## Code Review Process

1. **Automated Checks**: All tests must pass
2. **Manual Review**: Code quality, architecture fit
3. **Testing**: Reviewers will test your changes
4. **Documentation**: Ensure docs are updated

---

## Getting Help

- **Architecture Questions**: See THOUGHTS.md
- **Build Issues**: See INSTALLATION.md  
- **Style Questions**: See STYLEGUIDE.md
- **Testing Help**: Check existing tests in test/ directory

---

Thank you for contributing to usbX! Together we're building a robust USB microservice. 🚀  
