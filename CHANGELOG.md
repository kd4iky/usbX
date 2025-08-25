# Changelog

All notable changes to the usbX microservice will be documented in this file.  
This project follows [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Planned Features
- **HTTP Server**: Implement libmicrohttpd-based REST API
- **JSON Endpoints**: Device enumeration, open/close, transfer operations
- **Authentication**: API key-based authentication system
- **Configuration**: File-based configuration management
- **WebSocket Support**: Real-time USB event notifications
- **Docker Integration**: Container support with USB passthrough

---

## [0.2.0] - 2025-08-25

### ✅ Added
- **libusb Integration**: Full USB device initialization and enumeration
  - Global context management with proper error handling
  - Device enumeration with `libusb_get_device_list`
  - Proper resource cleanup and exit codes
- **uthash Integration**: Thread-safe hash table for device handle management
  - Header-only library integration (`include/uthash.h`)
  - Device handle storage and lookup functionality
  - Memory management with proper cleanup
- **TDD Test Suite**: Comprehensive testing framework with 100% pass rate
  - `test_build.sh`: Build system validation
  - `test_uthash.sh`: Hash table integration tests
  - `test_libusb_init.sh`: libusb initialization tests  
  - `test_libusb_functionality.sh`: USB device enumeration tests
  - `run_all_tests.sh`: Comprehensive test runner
- **Build System**: Robust Makefile with automatic dependency detection
  - pkg-config integration for all dependencies
  - Automatic fallback for missing dependencies
  - Comprehensive test targets and help system
- **Documentation**: Complete project documentation overhaul
  - Updated README.md with current implementation status
  - Comprehensive INSTALLATION.md with troubleshooting
  - Detailed CONTRIBUTING.md with TDD workflow
  - Enhanced STYLEGUIDE.md with USB-specific patterns
  - CLAUDE.md for AI development assistance

### 🔧 Changed
- **Project Status**: Transitioned from "planning phase" to "foundation complete"
- **Architecture**: Established solid foundation with libusb + uthash integration
- **Error Handling**: Implemented robust error reporting with descriptive messages
- **Memory Management**: Proper resource allocation and cleanup patterns

### 🧪 Testing
- **4 Test Categories**: Build, integration, unit, and functionality tests
- **USB Device Detection**: Tests verify real USB device enumeration
- **100% Pass Rate**: All tests passing in current implementation
- **TDD Workflow**: Test-first development process established

---

## [0.1.0] - 2025-01-01

### Added  
- **Initial Project Structure**: Created usbX microservice project
  - Project documentation (README, LICENSE, CONTRIBUTING, etc.)
  - Basic Makefile structure
  - Git repository initialization
- **Architecture Design**: Detailed microservice architecture in THOUGHTS.md
  - HTTP-based USB device access design
  - libusb + libmicrohttpd + json-c architecture
  - Thread-per-connection model specification
  - RESTful API endpoint design

---

## Development Notes

### Current Implementation Status (v0.2.0)
```
✅ libusb Integration      - Device init/enumeration working
✅ uthash Integration      - Hash table management working  
✅ TDD Test Suite         - Comprehensive testing (4 categories)
✅ Build System           - pkg-config dependency detection
✅ Documentation          - Complete docs overhaul
🚧 HTTP Server           - Ready for libmicrohttpd integration
🚧 JSON API              - Ready for json-c integration
🚧 Configuration         - File-based config planned
```

### Dependencies Status
- **libusb-1.0**: ✅ Integrated and tested (v1.0.27+)
- **libmicrohttpd**: ✅ Detected, ready for integration
- **json-c**: ✅ Detected, ready for integration  
- **uthash**: ✅ Integrated header-only library

### Test Coverage
- **Build Tests**: ✅ Makefile, compilation, linking
- **Integration Tests**: ✅ uthash hash table operations
- **Unit Tests**: ✅ libusb context initialization
- **Functionality Tests**: ✅ USB device enumeration

### Next Development Phase
The project has established a solid foundation and is ready for HTTP server implementation. The next major version (0.3.0) will focus on implementing the RESTful API layer using libmicrohttpd and json-c.