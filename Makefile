# Makefile for usbX microservice
# TDD-driven build system with dependency checking

# Project configuration
PROJECT_NAME = usbx
SRC_DIR = src
INCLUDE_DIR = include
BUILD_DIR = build
TARGET = $(PROJECT_NAME)

# Compiler settings
CC = gcc
CFLAGS = -std=c99 -Wall -Wextra -g
LDFLAGS = -pthread

# Include paths - check both include/ and src/ for headers
INCLUDE_PATHS = -I$(INCLUDE_DIR)
ifneq ($(wildcard $(SRC_DIR)/*.h),)
    INCLUDE_PATHS += -I$(SRC_DIR)
endif

# Dependencies - check with pkg-config
DEPS = libusb-1.0 libmicrohttpd json-c
PKG_CFLAGS = $(shell pkg-config --cflags $(DEPS) 2>/dev/null)
PKG_LIBS = $(shell pkg-config --libs $(DEPS) 2>/dev/null)

# Check if dependencies are available
DEPS_AVAILABLE = $(shell pkg-config --exists $(DEPS) 2>/dev/null && echo "yes" || echo "no")

# Use dependencies if available, otherwise build minimal version
ifeq ($(DEPS_AVAILABLE),yes)
    CFLAGS += $(PKG_CFLAGS) $(INCLUDE_PATHS) -DUSE_DEPS
    LDFLAGS += $(PKG_LIBS)
else
    # Minimal build without dependencies
    CFLAGS += $(INCLUDE_PATHS) -DMINIMAL_BUILD
    LDFLAGS += 
endif

# Source files
SOURCES = $(wildcard $(SRC_DIR)/*.c)
OBJECTS = $(SOURCES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)

# Default target
all: check-deps $(TARGET)

# Check if dependencies are available
check-deps:
	@echo "Checking dependencies..."
ifeq ($(DEPS_AVAILABLE),yes)
	@echo "All dependencies found via pkg-config"
	@for dep in $(DEPS); do \
		echo "  ✓ $$dep"; \
	done
	@echo "Building with full functionality"
else
	@echo "Dependencies not found - building minimal version"
	@echo "To install dependencies on Ubuntu/Debian:"
	@echo "  sudo apt-get install libusb-1.0-0-dev libmicrohttpd-dev libjson-c-dev"
	@echo "Building minimal version without external dependencies"
endif
	@echo

# Create build directory
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Compile object files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	@echo "Compiling $<..."
	$(CC) $(CFLAGS) $(PKG_CFLAGS) -c $< -o $@

# Link executable
$(TARGET): $(OBJECTS)
	@echo "Linking $(TARGET)..."
	$(CC) $(OBJECTS) -o $(TARGET) $(PKG_LIBS) $(LDFLAGS)
	@echo "Build complete: $(TARGET)"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR) $(TARGET)
	@echo "Clean complete."

# Run the executable
run: $(TARGET)
	@echo "Running $(TARGET)..."
	./$(TARGET)

# Install target (placeholder)
install: $(TARGET)
	@echo "Install target not yet implemented"

# Test targets
test: test-build test-uthash test-libusb test-libusb-functionality
	@echo "All tests completed successfully!"

test-build:
	@echo "Running build tests..."
	@test/test_build.sh

test-uthash:
	@echo "Running uthash integration tests..."
	@test/test_uthash.sh

test-libusb:
	@echo "Running libusb initialization tests..."
	@test/test_libusb_init.sh

test-libusb-functionality:
	@echo "Running libusb functionality tests..."
	@test/test_libusb_functionality.sh

# Generate documentation with Doxygen
docs:
	@if command -v doxygen >/dev/null 2>&1; then \
		echo "Generating documentation with Doxygen..."; \
		doxygen Doxyfile; \
		echo "Documentation generated in docs/html/index.html"; \
	else \
		echo "Error: doxygen not found. Install with: sudo apt-get install doxygen"; \
		exit 1; \
	fi

# Help target
help:
	@echo "usbX Makefile targets:"
	@echo "  all        - Build the project (default)"
	@echo "  clean      - Remove build artifacts"
	@echo "  run        - Build and run the executable"
	@echo "  test       - Run all tests"
	@echo "  test-build - Run build system tests"
	@echo "  test-uthash- Run uthash integration tests"
	@echo "  test-libusb- Run libusb initialization tests"
	@echo "  test-libusb-functionality - Run libusb functionality tests"
	@echo "  docs       - Generate Doxygen documentation"
	@echo "  install    - Install the executable (not implemented)"
	@echo "  check-deps - Check for required dependencies"
	@echo "  help       - Show this help message"

# Declare phony targets
.PHONY: all clean run install help check-deps test test-build test-uthash test-libusb test-libusb-functionality docs