# usbX - libusb Microservice

**usbX** is a C-based microservice for Linux that provides HTTP-based access to USB devices. It wraps libusb operations in a RESTful API, allowing containerized or remote applications to interact with USB hardware without direct access.

---

## Project Status

This project has a **solid foundation implemented** with core USB functionality working.  

### ✅ **Currently Implemented:**
- **libusb Integration** - Full USB device initialization and enumeration
- **Device Handle Management** - Thread-safe hash table using uthash
- **TDD Test Suite** - Comprehensive testing framework with 100% pass rate
- **Build System** - Automatic dependency detection via pkg-config
- **Error Handling** - Robust error reporting with proper exit codes

### 🚧 **Next Development Phase:**
- HTTP Server implementation (libmicrohttpd integration)
- RESTful API endpoints for USB operations
- JSON request/response handling

---

## Features & Capabilities

- **USB Device Access**: Initialize, enumerate, and manage USB devices via libusb-1.0
- **Hash Table Management**: Efficient device handle storage and lookup
- **Memory Management**: Proper resource allocation and cleanup
- **Error Handling**: Comprehensive error reporting with descriptive messages
- **Test Coverage**: Full TDD test suite with build, integration, and functionality tests
- **Cross-Platform**: Built for Linux with standard POSIX libraries  

---

## Quick Start

### Prerequisites
```bash
# Ubuntu/Debian
sudo apt-get install libusb-1.0-0-dev libmicrohttpd-dev libjson-c-dev

# Verify installation
make check-deps
```

### Build and Run
```bash
# Clone and build
git clone <repository-url>
cd usbX
make

# Run the current implementation
./usbx
```

### Expected Output
```
usbX microservice starting...
Testing uthash integration...
✓ uthash working: Found handle with ID 1
Initializing libusb...
✓ libusb initialized successfully
usbX service ready!
```

### Testing
```bash
make test                         # Run all tests
make test-libusb-functionality   # Test USB device enumeration
```

---

## Architecture

- **libusb-1.0**: USB device access and management
- **uthash**: Thread-safe hash table for device handle storage  
- **libmicrohttpd**: HTTP server (ready for integration)
- **json-c**: JSON parsing (ready for integration)
- **TDD Framework**: Comprehensive test coverage

---

## Contributing & Collaboration

This project follows Test-Driven Development (TDD) practices.  

**Development Workflow:**
1. Fork the repository
2. Run the test suite: `make test`
3. Create a new branch (`feature/your-feature` or `fix/your-bug`)
4. Write tests for new functionality
5. Implement code to make tests pass
6. Ensure all tests pass: `make test`
7. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## License

This project is licensed under the **GNU General Public License v3.0 (GPLv3)**.  
You are free to use, modify, and distribute this software, but any derivative works must also be licensed under the GPLv3.  

See the full [LICENSE](LICENSE.md) file for details.
