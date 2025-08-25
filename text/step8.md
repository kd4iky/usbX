### Testing and Debugging

The provided step outlines the basic process for testing and debugging the `usbX` microservice, including compilation, endpoint testing with curl, USB device verification, and debugging with tools like gdb and valgrind. While it’s a good starting point, it can be expanded with detailed instructions for setting up a comprehensive testing strategy, specific test cases for each endpoint, advanced debugging techniques, logging enhancements, and considerations for continuous integration (CI). This expansion will ensure thorough validation of the microservice’s functionality, performance, and stability, making it actionable for a C programmer. Below is the expanded version:

- **Compile and Run the Microservice**:
  - Ensure the project is set up as per prior steps (e.g., Makefile, dependencies like libusb, libmicrohttpd, json-c, and uthash).
  - Compile the project: Run `make` in the `usbX` directory to build the `usbx` executable. The Makefile (from the project structure step) should include:
    ```makefile
    CC = gcc
    CFLAGS = -Wall -Wextra -O2 $(shell pkg-config --cflags libusb-1.0 libmicrohttpd json-c)
    LDFLAGS = $(shell pkg-config --libs libusb-1.0 libmicrohttpd json-c) -lpthread
    SRC = src/main.c
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
  - Run the microservice: Execute `make run` or `./usbx` to start the server on port 8080 (or as defined in `PORT`). Ensure you’re in the `plugdev` group (`sudo usermod -aG plugdev $USER`, then log out/in) to access USB devices without root.
  - Verify startup: Check console output for errors (e.g., "Failed to initialize libusb"). If the server starts, it should print something like "Server running on port 8080. Press Enter to stop...".
  - Troubleshooting:
    - If compilation fails, verify dependencies with `pkg-config --modversion libusb-1.0 libmicrohttpd json-c`.
    - If the server fails to start (e.g., port in use), check with `netstat -tuln | grep 8080` and change `PORT` or kill the conflicting process.

- **Test Endpoints Locally with curl**:
  - Use `curl` to test each API endpoint, ensuring they respond correctly and handle errors. Run these commands in a separate terminal while `usbx` is running.
  - **GET /devices**:
    ```bash
    curl -u admin:usbXpass123 http://localhost:8080/devices
    ```
    - Expected: JSON array like `[{"bus":1, "address":2, "vid":1234, "pid":5678, "description":"USB Device"}]`.
    - Test cases:
      - Valid response: Connect a USB device (e.g., flash drive) and verify its details appear.
      - Empty list: Disconnect all USB devices and expect `{"devices": []}`.
      - Error case: Simulate libusb failure (e.g., unplug device during enumeration) and expect `{"error": "LIBUSB_ERROR_IO", "code": -1, "message": "Input/output error"}`.
  - **POST /open**:
    ```bash
    curl -u admin:usbXpass123 -X POST -H "Content-Type: application/json" \
         -d '{"bus":1, "address":2}' http://localhost:8080/open
    ```
    - Expected: `{"handle_id": 1}`.
    - Test cases:
      - Valid device: Use bus/address from `/devices` output.
      - Invalid device: Use `{"bus":999, "address":999}` and expect `{"error": "Device not found"}`.
      - VID/PID: Test `{"vid":1234, "pid":5678}` for a known device.
      - Bad JSON: Send `{"bus":"invalid"}` and expect `{"error": "Invalid JSON"}`.
  - **POST /handles/{id}/control**:
    ```bash
    curl -u admin:usbXpass123 -X POST -H "Content-Type: application/json" \
         -d '{"bmRequestType":0x80, "bRequest":6, "wValue":0x0300, "wIndex":0}' \
         http://localhost:8080/handles/1/control
    ```
    - Expected: `{"bytes_transferred": N, "data": "base64_encoded"}` (for IN transfer).
    - Test cases:
      - Valid IN transfer: Use standard USB control request (e.g., get descriptor).
      - OUT transfer: Send `{"data": "base64_encoded"}` with valid base64.
      - Invalid handle: Use `/handles/999/control` and expect `{"error": "Handle not found"}`.
      - Timeout: Set `{"timeout": 1}` for a slow device and expect `{"error": "LIBUSB_ERROR_TIMEOUT"}`.
  - **POST /handles/{id}/bulk**:
    ```bash
    curl -u admin:usbXpass123 -X POST -H "Content-Type: application/json" \
         -d '{"endpoint":0x81, "timeout":1000}' http://localhost:8080/handles/1/bulk
    ```
    - Test cases similar to `/control`, ensuring endpoint matches device configuration (use `lsusb -v` to find endpoints).
  - **POST /handles/{id}/close**:
    ```bash
    curl -u admin:usbXpass123 -X POST http://localhost:8080/handles/1/close
    ```
    - Expected: `{"status": "closed"}`.
    - Test cases:
      - Valid handle: Close an opened handle.
      - Invalid handle: Expect `{"error": "Handle not found"}`.
  - **GET /health**:
    ```bash
    curl http://localhost:8080/health
    ```
    - Expected: `{"status": "ok"}`.
    - Test without auth to verify it’s accessible.
  - **Authentication**:
    - Test invalid credentials: `curl -u wrong:pass http://localhost:8080/devices` (expect `{"error": "Unauthorized"}`).
    - Test missing auth: `curl http://localhost:8080/devices` (expect 401).

- **Verify Device Interactions with usbutils**:
  - Install usbutils: `sudo apt install usbutils` (or `dnf install usbutils` on Fedora).
  - Use `lsusb` to list connected devices and verify bus/address/VID/PID match `/devices` output:
    ```bash
    lsusb
    ```
    - Example output: `Bus 001 Device 002: ID 1234:5678 Vendor Product`.
  - Use `lsusb -v` to inspect endpoints for bulk/interrupt transfers or `dmesg | grep usb` to monitor kernel logs for device attach/detach events.
  - Test auto-detach: Connect a device with a kernel driver (e.g., a USB flash drive), open it via `/open`, and verify it works without manual `sudo modprobe -r usb-storage`.
  - Troubleshooting:
    - If devices don’t appear, check permissions (`/dev/bus/usb`) and ensure the user is in `plugdev`.
    - Use `sudo udevadm monitor` to debug device events during testing.

- **Debug with gdb and valgrind**:
  - **gdb**:
    - Compile with debug symbols: Modify Makefile to include `CFLAGS += -g`.
    - Run in gdb: `gdb ./usbx`, then `run`. Set breakpoints, e.g., `break request_handler` or `break libusb_open`.
    - Test a specific endpoint: Use curl while gdb is running, then step through (`next`, `step`) to inspect variables or errors.
    - Example: `print *entry` in `find_handle` to check handle state.
  - **valgrind**:
    - Install valgrind: `sudo apt install valgrind`.
    - Run: `valgrind --leak-check=full ./usbx`.
    - Test with curl requests and check for memory leaks (e.g., unclosed handles, unfreed JSON objects).
    - Fix common issues: Ensure `json_object_put`, `free` on base64 buffers, and `libusb_close` in `remove_handle`.
  - **Logging**:
    - Enhance logging from the error handling step:
      ```c
      static FILE *log_file = NULL;
      void log_error(const char *fmt, ...) {
          if (!log_file) log_file = fopen("/var/log/usbx.log", "a");
          if (log_file) {
              va_list args;
              va_start(args, fmt);
              fprintf(log_file, "[%s] ", __TIMESTAMP__);
              vfprintf(log_file, fmt, args);
              fprintf(log_file, "\n");
              fflush(log_file);
              va_end(args);
          }
          // Also log to stderr for immediate feedback
          va_start(args, fmt);
          vfprintf(stderr, fmt, args);
          va_end(args);
          fprintf(stderr, "\n");
      }
      ```
    - Use in endpoints, e.g., `log_error("libusb_open failed: %s", libusb_error_name(ret))`.
    - Ensure log file permissions: `sudo chown $USER /var/log/usbx.log`.

- **Additional Testing Strategies**:
  - **Automated Tests**:
    - Write a shell script to automate curl tests:
      ```bash
      #!/bin/bash
      echo "Testing /health..."
      curl http://localhost:8080/health
      echo "Testing /devices..."
      curl -u admin:usbXpass123 http://localhost:8080/devices
      echo "Testing /open..."
      curl -u admin:usbXpass123 -X POST -d '{"bus":1,"address":2}' http://localhost:8080/open
      # Add more tests
      ```
      - Save as `test.sh`, run with `bash test.sh`.
    - Use a testing framework like Check (C unit testing): `sudo apt install check`, then write tests for handle management functions (`add_handle`, `find_handle`).
  - **Concurrency Testing**:
    - Simulate multiple clients: `for i in {1..10}; do curl -u admin:usbXpass123 http://localhost:8080/devices & done`.
    - Verify no crashes or race conditions (mutexes in `handles` should prevent issues).
  - **Edge Cases**:
    - Test device disconnection: Unplug a device after opening it, then try `/handles/{id}/control` (expect `LIBUSB_ERROR_NO_DEVICE`).
    - Test large payloads: Send a large base64-encoded `data` field in `/bulk` to verify buffer handling.
    - Test timeouts: Set low `timeout` values (e.g., 1ms) for slow devices.

- **Continuous Integration (CI)**:
  - Set up GitHub Actions for automated testing:
    - Create `.github/workflows/ci.yml`:
      ```yaml
      name: CI
      on: [push, pull_request]
      jobs:
        build:
          runs-on: ubuntu-latest
          steps:
            - uses: actions/checkout@v3
            - name: Install dependencies
              run: sudo apt update && sudo apt install -y libusb-1.0-0-dev libmicrohttpd-dev libjson-c-dev gcc make
            - name: Build
              run: make
            - name: Run tests
              run: |
                ./usbx &
                sleep 2
                bash test.sh
      ```
    - This builds and tests on every push/PR, but note USB testing requires physical devices, so CI may be limited to compilation and `/health`.
  - Local simulation: Use a virtual USB device (e.g., via `vusb-analyzer`) for CI if needed.

- **Performance and Stress Testing**:
  - Use `ab` (Apache Benchmark): `sudo apt install apache2-utils`, then `ab -n 1000 -c 10 -A admin:usbXpass123 http://localhost:8080/devices` to test throughput.
  - Monitor with `top` or `htop` to ensure CPU/memory usage is reasonable.
  - Profile with `perf`: `sudo apt install linux-tools-common linux-tools-$(uname -r)`, then `perf record ./usbx` and `perf report` to identify bottlenecks.

- **Troubleshooting Tips**:
  - If endpoints fail, check logs (`/var/log/usbx.log` or stderr).
  - If devices aren’t detected, verify with `lsusb` and check udev rules (`/etc/udev/rules.d/`).
  - If memory leaks occur, rerun valgrind with `--show-leak-kinds=all`.

This expanded step provides a comprehensive testing and debugging strategy with specific commands, code enhancements, and automation. It covers functional, error, and performance testing, making it production-ready while remaining clear for implementation. If you need further details (e.g., specific test cases for a device or CI setup), let me know!
