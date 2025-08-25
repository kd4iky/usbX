# usbX Installation Guide

This document provides instructions for installing and building the usbX microservice.

---

## System Requirements

- **Operating System**: Linux (tested on Ubuntu/Debian)
- **Architecture**: ARM64, x86_64
- **Compiler**: GCC with C99 support
- **Build Tools**: make, pkg-config

---

## Dependencies

### Required Dependencies:
- **libusb-1.0-dev** (≥1.0.20) - USB device access
- **libmicrohttpd-dev** (≥0.9.70) - HTTP server (for future implementation)
- **libjson-c-dev** (≥0.13) - JSON parsing (for future implementation)

### Install Dependencies:

#### Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install libusb-1.0-0-dev libmicrohttpd-dev libjson-c-dev build-essential pkg-config
```

#### Verification:
```bash
pkg-config --exists libusb-1.0 && echo "libusb-1.0: ✓" || echo "libusb-1.0: ✗"
pkg-config --exists libmicrohttpd && echo "libmicrohttpd: ✓" || echo "libmicrohttpd: ✗"
pkg-config --exists json-c && echo "json-c: ✓" || echo "json-c: ✗"
```

---

## Build Instructions

### Quick Build:
```bash
git clone <repository-url>
cd usbX
make
```

### Detailed Build Process:

1. **Clone Repository:**
   ```bash
   git clone <repository-url>
   cd usbX
   ```

2. **Verify Dependencies:**
   ```bash
   make check-deps
   ```
   Expected output:
   ```
   Checking dependencies...
   All dependencies found via pkg-config
     ✓ libusb-1.0
     ✓ libmicrohttpd
     ✓ json-c
   Building with full functionality
   ```

3. **Build Project:**
   ```bash
   make clean      # Clean any previous build
   make            # Build the project
   ```

4. **Run Tests:**
   ```bash
   make test       # Run complete test suite
   ```

### Alternative Build Methods:

#### Manual Compilation:
```bash
gcc src/main.c -o usbx \
  -lusb-1.0 -lmicrohttpd -ljson-c -pthread \
  -Iinclude -Isrc -std=c99 -Wall -Wextra
```

#### CMake Support:
```bash
mkdir build && cd build
cmake ..
make
```
*(Note: CMake configuration planned for future versions)*

---

## Installation

### Local Installation:
```bash
# Build and run locally
make
./usbx
```

### System Installation:
```bash
sudo make install
```
*(Note: Install target planned for future versions)*

---

## Verification

### Test Build Success:
```bash
./usbx
```

**Expected Output:**
```
usbX microservice starting...
Testing uthash integration...
✓ uthash working: Found handle with ID 1
Initializing libusb...
✓ libusb initialized successfully
usbX service ready!
```

### Test Suite Verification:
```bash
make test
```

**Expected Results:**
- ✅ Build system tests
- ✅ uthash integration tests  
- ✅ libusb initialization tests
- ✅ libusb functionality tests

### Verify USB Device Enumeration:
```bash
make test-libusb-functionality
```

This should show the number of USB devices detected on your system.

---

## Troubleshooting

### Common Issues:

#### 1. "libusb-1.0 not found"
```bash
# Check if installed
dpkg -l | grep libusb-1.0-0-dev

# Install if missing
sudo apt-get install libusb-1.0-0-dev
```

#### 2. "Permission denied" for USB access
```bash
# Add user to plugdev group (may require logout/login)
sudo usermod -a -G plugdev $USER

# Or run with sudo for testing
sudo ./usbx
```

#### 3. Build fails with missing headers
```bash
# Install development packages
sudo apt-get install build-essential pkg-config

# Verify pkg-config can find libraries
pkg-config --cflags --libs libusb-1.0
```

#### 4. "No USB devices found"
This is normal if no USB devices are connected or if running in a container without USB access.

---

## Development Build

For development with debugging symbols:
```bash
make clean
CFLAGS="-g -O0 -DDEBUG" make
```

For release build:
```bash
make clean  
CFLAGS="-O2 -DNDEBUG" make
```

---

## Next Steps

After successful installation:
1. Run the test suite: `make test`
2. Explore the codebase: see `src/main.c`
3. Read the architecture: see `THOUGHTS.md`
4. Contribute: see `CONTRIBUTING.md`