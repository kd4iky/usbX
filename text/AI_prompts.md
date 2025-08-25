To break down the development of the `usbX` microservice into small, testable steps following the Test-Driven Development (TDD) methodology, I’ll analyze the provided documentation (steps 1–10) and create a sequence of granular tasks. Each task will include a specific requirement, a failing test to define the expected behavior, and the minimal code to make the test pass, adhering to the red-green-refactor cycle. I’ll ensure the steps are sequential, build on each other, and cover the key components outlined in the documents, including project setup, libusb initialization, HTTP server, state management, RESTful endpoints, JSON/binary data handling, error handling, security, testing, deployment, and extensions like async transfers and hotplug support.

Each step will include an AI prompt that instructs an AI system to critically analyze the task, write a failing test, implement the minimal code to pass the test, and refactor if necessary. The prompts will emphasize clear, meaningful tests that serve as documentation and validation, aligning with the user’s specified response style. Since the project is complex, I’ll break it into approximately 30–40 small steps to ensure manageability and testability, covering all aspects from setup to advanced features. I’ll also ensure thread safety, error handling, and production-readiness where applicable, referencing the provided code snippets and expanding where necessary.

### Development Steps for `usbX` Microservice

Below is the list of small, testable steps, each with an AI prompt. The steps are grouped logically based on the provided documentation, starting with setup and progressing to advanced features. Each step focuses on a single unit of functionality, with tests that validate specific behavior. The prompts are designed to guide an AI to critically analyze the requirements, write tests first, and implement minimal code to pass, followed by optional refactoring.

---

#### Step 1: Set Up Project Directory and Makefile
**Requirement**: Create the project directory structure with a `src/` directory, an empty `main.c`, and a `Makefile` that compiles with dependencies (libusb, libmicrohttpd, json-c, pthread) and supports clean/run targets.

**AI Prompt**:
```
You are a test-driven development (TDD) expert tasked with setting up the project directory and Makefile for the `usbX` microservice. Critically analyze the requirement to create a directory structure with `src/main.c` and a Makefile that compiles using gcc, links libusb-1.0, libmicrohttpd, json-c, and pthread, and includes targets for building, cleaning, and running. Break this into the smallest testable unit: a Makefile that compiles an empty `main.c` without errors. Write a failing test (e.g., a shell script that runs `make` and checks for the executable). Then, provide the minimal code for `src/main.c` and `Makefile` to pass the test. Refactor if needed to ensure clarity and robustness, considering dependency checks via pkg-config and proper include paths. Output the test, code, and any refactoring notes in a clear, structured format.
```

---

#### Step 2: Download and Include Uthash
**Requirement**: Download `uthash.h` and place it in `src/`, ensuring it’s included in `main.c` without compilation errors.

**AI Prompt**:
```
As a TDD expert, analyze the requirement to include the uthash header-only library in the `usbX` project. The smallest testable unit is downloading `uthash.h` to `src/` and including it in `main.c` with a successful compilation. Write a failing test (e.g., a shell script that checks for `src/uthash.h` and compiles `main.c` with `#include "uthash.h"`). Provide the minimal code (empty `main.c` with the include and a script to download `uthash.h`). Refactor to ensure the include path is robust (e.g., handle `include/` if used later). Output the test, code, and refactoring notes clearly.
```

---

#### Step 3: Initialize libusb Context
**Requirement**: Initialize a global `libusb_context` in `main.c` with proper error handling, returning `EXIT_FAILURE` on error.

**AI Prompt**:
```
You are a TDD expert implementing libusb initialization for the `usbX` microservice. Analyze the requirement to initialize a global `libusb_context *ctx` in `main.c`, checking the return code of `libusb_init` and exiting with `EXIT_FAILURE` on error. The smallest testable unit is a `main` function that initializes the context and exits with the correct status. Write a failing test (e.g., a C unit test using Check that calls `main` and checks the exit code for success or failure). Provide minimal code in `main.c` to pass the test, including necessary includes (`libusb-1.0/libusb.h`, `stdlib.h`). Refactor to add error logging to stderr. Output the test, code, and refactoring notes.
```

---

#### Step 4: Define HandleEntry Struct and Global Variables
**Requirement**: Define the `HandleEntry` struct for uthash, declare global `handles`, `handles_mutex`, and `next_handle_id` in `main.c`.

**AI Prompt**:
```
As a TDD expert, analyze the requirement to define a `HandleEntry` struct for uthash-based USB handle management, with globals for the hash map (`handles`), mutex (`handles_mutex`), and ID counter (`next_handle_id`). The smallest testable unit is compiling `main.c` with the struct and globals without errors. Write a failing test (e.g., a shell script that compiles `main.c` with these declarations). Provide minimal code to define the struct and globals, including necessary includes (`uthash.h`, `pthread.h`). Refactor to ensure proper initialization (e.g., mutex initializer). Output the test, code, and refactoring notes clearly.
```

---

#### Step 5: Implement add_handle Function
**Requirement**: Implement a thread-safe `add_handle` function to add a `libusb_device_handle *` to the hash map with a unique ID.

**AI Prompt**:
```
You are a TDD expert implementing the `add_handle` function for the `usbX` microservice. Analyze the requirement to create a thread-safe function that adds a `libusb_device_handle *` to the `handles` hash map with a unique ID, using `handles_mutex` and `next_handle_id`. The smallest testable unit is adding a handle and retrieving its ID. Write a failing test (e.g., a C unit test that calls `add_handle` with a NULL handle and checks the returned ID). Provide minimal code for `add_handle` to pass the test, handling memory allocation and mutex locking. Refactor to add error logging and null checks. Output the test, code, and refactoring notes.
```

---

You are a test-driven development (TDD) expert tasked with generating additional test cases for the project directory and Makefile setup of the `usbX` microservice, building on a completed and passing implementation. The existing setup includes a directory structure with `src/main.c` and a `Makefile` that compiles using `gcc`, links `libusb-1.0`, `libmicrohttpd`, `json-c`, and `pthread`, and supports `make`, `make clean`, and `make run` targets. The original test (a shell script) verified that `make` compiles an empty `src/main.c` into the `usbx` executable without errors. Your task is to critically analyze the setup requirements and generate additional test cases, including edge cases, to ensure robustness. Focus on the smallest testable units, such as dependency handling, error cases, and target behaviors.

### Steps to Follow:
1. **Analyze the Requirement**:
   - Review the need for a project directory (`usbX` with `src/main.c`) and a `Makefile` that uses `pkg-config` for library flags, compiles `main.c`, links required libraries, and supports `clean` and `run` targets.
   - Identify edge cases, such as missing dependencies (e.g., `libusb-1.0` not installed), invalid source files (e.g., syntax errors in `main.c`), missing `src/` directory, and incorrect `pkg-config` output.
   - Consider additional scenarios, such as verifying `make clean` removes artifacts, `make run` executes the binary, and handling spaces or special characters in paths.

2. **Generate Test Cases**:
   - Write at least five new test cases, including:
     - **Dependency Failure**: Test compilation failure when a required library (e.g., `libusb-1.0`) is missing.
     - **Invalid Source File**: Test compilation failure when `main.c` contains a syntax error.
     - **Missing src Directory**: Test `make` failure when `src/` or `main.c` is missing.
     - **Clean Target**: Verify `make clean` removes object files and the executable.
     - **Run Target**: Verify `make run` builds and executes `usbx` successfully.
     - **Edge Case - Special Characters**: Test compilation with a project path containing spaces or special characters.
   - For each test case, create a shell script (or equivalent) that sets up the scenario, runs `make` (or the relevant target), and checks the expected outcome (e.g., exit codes, file presence, or error messages).
   - Ensure tests are independent, automated, and produce clear pass/fail results.

3. **Verify Existing Implementation**:
   - Assume the existing `Makefile` and `src/main.c` are minimal (e.g., empty `main.c` with `int main() { return 0; }` and a `Makefile` using `pkg-config` for libraries). Test whether these handle the new cases correctly or require updates.
   - If the implementation needs changes to pass new tests (e.g., better error messages or dependency checks), note the required modifications but do not implement them (focus on test generation).

4. **Output Format**:
   - Provide each test case in a clear, structured format:
     - **Test Case Name**: Descriptive name (e.g., "Test Missing Library Dependency").
     - **Description**: What the test verifies and why it’s important (including edge case rationale).
     - **Test Code**: Shell script (or equivalent) that sets up the scenario, runs the test, and checks the result.
     - **Expected Outcome**: What constitutes a pass (e.g., specific error message, file absence).
     - **Edge Case Notes**: Why this tests an edge case or critical scenario.
   - Summarize any potential changes needed in the `Makefile` or `main.c` to pass the new tests, but do not modify the code unless explicitly required.
   - Include a brief section on refactoring considerations (e.g., adding dependency checks in the `Makefile` or improving error messages).

5. **Constraints**:
   - Tests must be automatable and runnable on a Linux system (e.g., Ubuntu 22.04).
   - Assume dependencies (`libusb-1.0`, `libmicrohttpd`, `json-c`, `pthread`) are normally installed but can be mocked or removed for edge cases.
   - Use standard tools like `bash`, `make`, `gcc`, and `pkg-config` for tests.
   - Ensure tests align with the TDD principle of defining expected behavior before implementation changes.

Output the test cases, expected outcomes, edge case notes, and refactoring considerations in a clear, structured format. If the existing implementation (from step1.md and step2.md) is likely to fail any test, note the expected failure and suggest minimal changes without implementing them.

---

#### Step 6: Implement find_handle Function
**Requirement**: Implement a thread-safe `find_handle` function to retrieve a `HandleEntry` by ID from the hash map.

**AI Prompt**:
```
As a TDD expert, analyze the requirement to implement a thread-safe `find_handle` function that retrieves a `HandleEntry` by ID from the `handles` hash map using `uthash.h`. The smallest testable unit is finding a handle after adding it. Write a failing test (e.g., a C unit test that adds a handle, calls `find_handle`, and checks the returned entry). Provide minimal code for `find_handle` to pass the test, using `HASH_FIND_INT` and mutex locking. Refactor to optimize lookup performance and add logging for debugging. Output the test, code, and refactoring notes.
```

---

#### Step 7: Implement remove_handle Function
**Requirement**: Implement a thread-safe `remove_handle` function to remove and free a handle from the hash map, closing the USB handle.

**AI Prompt**:
```
You are a TDD expert implementing the `remove_handle` function for the `usbX` microservice. Analyze the requirement to create a thread-safe function that removes a `HandleEntry` by ID, closes the `libusb_device_handle`, and frees memory. The smallest testable unit is removing a handle and verifying it’s no longer in the hash map. Write a failing test (e.g., a C unit test that adds a handle, removes it, and checks `find_handle` returns NULL). Provide minimal code for `remove_handle` using `HASH_DEL`, `libusb_close`, and mutex locking. Refactor to add logging and handle edge cases (e.g., non-existent ID). Output the test, code, and refactoring notes.
```

---

#### Step 8: Implement cleanup_handles Function
**Requirement**: Implement a `cleanup_handles` function to free all handles and clean up the hash map on shutdown.

**AI Prompt**:
```
As a TDD expert, analyze the requirement to implement a `cleanup_handles` function that frees all `HandleEntry` structs, closes their USB handles, and clears the `handles` hash map. The smallest testable unit is adding multiple handles, calling `cleanup_handles`, and verifying the hash map is empty. Write a failing test (e.g., a C unit test that adds handles, calls `cleanup_handles`, and checks `handles` is NULL). Provide minimal code for `cleanup_handles` using `HASH_ITER`, `libusb_close`, and mutex locking. Refactor to ensure robust cleanup and add logging. Output the test, code, and refactoring notes.
```

---

#### Step 9: Start libusb Event Thread
**Requirement**: Create a background thread to handle libusb events using `libusb_handle_events`.

**AI Prompt**:
```
You are a TDD expert implementing a background thread for libusb event handling in the `usbX` microservice. Analyze the requirement to create a thread that calls `libusb_handle_events` in a loop, exiting on fatal errors. The smallest testable unit is starting the thread and verifying it runs without crashing. Write a failing test (e.g., a C unit test that starts the thread and checks it’s alive via `pthread_kill`). Provide minimal code for the thread function and its creation in `main`. Refactor to add error logging and adjust sleep intervals for CPU efficiency. Output the test, code, and refactoring notes.
```

---

#### Step 10: Start libmicrohttpd Daemon
**Requirement**: Initialize the libmicrohttpd daemon with `MHD_USE_THREAD_PER_CONNECTION` and a basic `request_handler`.

**AI Prompt**:
```
As a TDD expert, analyze the requirement to start a libmicrohttpd daemon in the `usbX` microservice with `MHD_USE_THREAD_PER_CONNECTION` and a minimal `request_handler`. The smallest testable unit is starting the daemon and verifying it listens on port 8080. Write a failing test (e.g., a shell script using `curl` to check if port 8080 responds). Provide minimal code for `MHD_start_daemon` and a stub `request_handler` returning a 404 JSON response. Refactor to add error logging and cleanup. Output the test, code, and refactoring notes.
```

---

#### Step 11: Implement send_json_response Helper
**Requirement**: Implement a helper function to send JSON responses with proper headers and status codes.

**AI Prompt**:
```
You are a TDD expert implementing a `send_json_response` helper for the `usbX` microservice. Analyze the requirement to create a function that sends a JSON string with the correct Content-Type header and HTTP status code. The smallest testable unit is sending a JSON response for a dummy request. Write a failing test (e.g., a C unit test that mocks a `MHD_Connection` and checks the response headers and body). Provide minimal code for `send_json_response` using `MHD_create_response_from_buffer`. Refactor to add CORS headers and error handling. Output the test, code, and refactoring notes.
```

---

#### Step 12: Implement parse_post_data Helper
**Requirement**: Implement a helper to accumulate and parse chunked POST data as JSON.

**AI Prompt**:
```
As a TDD expert, analyze the requirement to implement a `parse_post_data` function that accumulates chunked POST data and parses it as JSON using json-c. The smallest testable unit is parsing a single-chunk JSON POST body. Write a failing test (e.g., a C unit test that passes a JSON string to `parse_post_data` and checks the parsed `json_object`). Provide minimal code for `parse_post_data` using `json_tokener_parse`. Refactor to handle chunked data with a dynamic buffer. Output the test, code, and refactoring notes.
```

---

#### Step 13: Implement base64_encode Function
**Requirement**: Implement a `base64_encode` function to encode binary USB data for JSON responses.

**AI Prompt**:
```
You are a TDD expert implementing a `base64_encode` function for the `usbX` microservice. Analyze the requirement to encode binary data to base64 for JSON responses. The smallest testable unit is encoding a small binary buffer correctly. Write a failing test (e.g., a C unit test that passes a known buffer and checks the base64 output). Provide minimal code for `base64_encode` using a standard base64 table. Refactor to handle edge cases (e.g., empty input) and optimize memory usage. Output the test, code, and refactoring notes.
```

---

#### Step 14: Implement base64_decode Function
**Requirement**: Implement a `base64_decode` function to decode base64 data from JSON requests.

**AI Prompt**:
```
As a TDD expert, analyze the requirement to implement a `base64_decode` function that decodes base64 strings from JSON requests into binary data. The smallest testable unit is decoding a valid base64 string to the original binary. Write a failing test (e.g., a C unit test that passes a base64 string and checks the decoded output). Provide minimal code for `base64_decode` using a standard base64 table. Refactor to handle invalid base64 and add logging. Output the test, code, and refactoring notes.
```

---

#### Step 15: Implement GET /devices Endpoint
**Requirement**: Implement the GET /devices endpoint to list connected USB devices as JSON.

**AI Prompt**:
```
You are a TDD expert implementing the GET /devices endpoint for the `usbX` microservice. Analyze the requirement to list all connected USB devices using `libusb_get_device_list` and return their details (bus, address, VID, PID) as a JSON array. The smallest testable unit is returning an empty device list when no devices are connected. Write a failing test (e.g., a C unit test that mocks `libusb_get_device_list` to return no devices and checks the JSON response). Provide minimal code for the endpoint in `request_handler`. Refactor to handle non-empty lists and add error handling. Output the test, code, and refactoring notes.
```

---

#### Step 16: Implement POST /open Endpoint
**Requirement**: Implement the POST /open endpoint to open a USB device by bus/address or VID/PID and return a handle ID.

**AI Prompt**:
```
As a TDD expert, analyze the requirement to implement the POST /open endpoint that opens a USB device using `libusb_open` and stores it with `add_handle`. The smallest testable unit is parsing a JSON body with bus/address and returning a handle ID. Write a failing test (e.g., a C unit test that sends a mock JSON request and checks the handle ID). Provide minimal code for the endpoint, using `parse_post_data` and `add_handle`. Refactor to support VID/PID and add error handling. Output the test, code, and refactoring notes.
```

---

#### Step 17: Implement POST /handles/{id}/control Endpoint
**Requirement**: Implement the POST /handles/{id}/control endpoint for USB control transfers.

**AI Prompt**:
```
You are a TDD expert implementing the POST /handles/{id}/control endpoint for the `usbX` microservice. Analyze the requirement to perform a USB control transfer using `libusb_control_transfer` with parameters from a JSON body. The smallest testable unit is handling a valid JSON request for a control transfer and returning the result. Write a failing test (e.g., a C unit test that mocks a handle and JSON input, checking the JSON response). Provide minimal code for the endpoint, using `find_handle`, `parse_post_data`, and `base64_decode`. Refactor to handle IN/OUT transfers and timeouts. Output the test, code, and refactoring notes.
```

---

#### Step 18: Implement POST /handles/{id}/bulk Endpoint
**Requirement**: Implement the POST /handles/{id}/bulk endpoint for USB bulk transfers.

**AI Prompt**:
```
You are a TDD expert implementing the POST /handles/{id}/bulk endpoint for the `usbX` microservice. Analyze the requirement to perform a USB bulk transfer using `libusb_bulk_transfer` with endpoint and timeout from a JSON body. The smallest testable unit is handling a valid JSON request for a bulk IN transfer. Write a failing test (e.g., a C unit test that mocks a handle and JSON input, checking the JSON response with base64 data). Provide minimal code for the endpoint, using `find_handle`, `parse_post_data`, and `base64_encode`. Refactor to support OUT transfers and error handling. Output the test, code, and refactoring notes.
```

---

#### Step 19: Implement POST /handles/{id}/close Endpoint
**Requirement**: Implement the POST /handles/{id}/close endpoint to close a handle and remove it from the hash map.

**AI Prompt**:
```
You are a TDD expert implementing the POST /handles/{id}/close endpoint for the `usbX` microservice. Analyze the requirement to close a USB handle using `remove_handle` and return a success JSON response. The smallest testable unit is closing an existing handle and verifying it’s removed. Write a failing test (e.g., a C unit test that adds a handle, closes it, and checks `find_handle` returns NULL). Provide minimal code for the endpoint in `request_handler`. Refactor to add logging and handle non-existent IDs. Output the test, code, and refactoring notes.
```

---

#### Step 20: Implement GET /health Endpoint
**Requirement**: Implement the GET /health endpoint to return a simple status JSON response.

**AI Prompt**:
```
You are a TDD expert implementing the GET /health endpoint for the `usbX` microservice. Analyze the requirement to return a JSON response indicating the service is running. The smallest testable unit is returning `{"status": "ok"}` for a GET request. Write a failing test (e.g., a C unit test that mocks a GET request and checks the JSON response). Provide minimal code for the endpoint in `request_handler` using `send_json_response`. Refactor to include additional metrics (e.g., open handle count). Output the test, code, and refactoring notes.
```

---

#### Step 21: Implement libusb Error Mapping
**Requirement**: Implement a helper function to map libusb error codes to JSON error responses.

**AI Prompt**:
```
You are a TDD expert implementing a `libusb_error_to_json` helper for the `usbX` microservice. Analyze the requirement to map libusb error codes to JSON objects with error name, code, and message. The smallest testable unit is mapping `LIBUSB_ERROR_NO_DEVICE` to a JSON string. Write a failing test (e.g., a C unit test that calls the function and checks the JSON output). Provide minimal code for `libusb_error_to_json`. Refactor to cover all major libusb errors and add logging. Output the test, code, and refactoring notes.
```

---

#### Step 22: Implement Basic Authentication
**Requirement**: Add basic authentication to restrict access to all endpoints using hardcoded credentials.

**AI Prompt**:
```
You are a TDD expert implementing basic authentication for the `usbX` microservice. Analyze the requirement to check credentials in `request_handler` using libmicrohttpd’s basic auth API. The smallest testable unit is rejecting a request with incorrect credentials. Write a failing test (e.g., a C unit test that mocks a request with wrong credentials and checks for 401 status). Provide minimal code for `check_auth` and integration in `request_handler`. Refactor to use configurable credentials (e.g., env variables). Output the test, code, and refactoring notes.
```

---

#### Step 23: Enable Kernel Driver Auto-Detach
**Requirement**: Enable auto-detach of kernel drivers in POST /open using `libusb_set_auto_detach_kernel_driver`.

**AI Prompt**:
```
You are a TDD expert implementing kernel driver auto-detach for the `usbX` microservice. Analyze the requirement to enable auto-detach in POST /open using `libusb_set_auto_detach_kernel_driver`. The smallest testable unit is setting auto-detach on a handle and verifying no error (or ignoring `LIBUSB_ERROR_NOT_SUPPORTED`). Write a failing test (e.g., a C unit test that mocks `libusb_open` and checks auto-detach). Provide minimal code for POST /open with auto-detach. Refactor to handle errors gracefully. Output the test, code, and refactoring notes.
```

---

#### Step 24: Add Timeout Handling for Transfers
**Requirement**: Add timeout validation and handling for control and bulk transfers in their respective endpoints.

**AI Prompt**:
```
You are a TDD expert implementing timeout handling for USB transfers in the `usbX` microservice. Analyze the requirement to parse and validate a `timeout` field in JSON for `/handles/{id}/control` and `/bulk` endpoints, defaulting to 1000ms. The smallest testable unit is parsing a valid timeout and applying it to a control transfer. Write a failing test (e.g., a C unit test that sends a JSON request with timeout and checks `libusb_control_transfer` call). Provide minimal code for timeout parsing in the control endpoint. Refactor to enforce a timeout range and handle `LIBUSB_ERROR_TIMEOUT`. Output the test, code, and refactoring notes.
```

---

#### Step 25: Add File-Based Logging
**Requirement**: Implement file-based error logging to `/var/log/usbx.log`.

**AI Prompt**:
```
You are a TDD expert implementing file-based logging for the `usbX` microservice. Analyze the requirement to log errors to `/var/log/usbx.log` with timestamps. The smallest testable unit is writing a log message to the file. Write a failing test (e.g., a C unit test that calls `log_error` and checks the file contents). Provide minimal code for `log_error` to write to the file. Refactor to ensure thread-safe file access and proper permissions. Output the test, code, and refactoring notes.
```

---

#### Step 26: Update README.md
**Requirement**: Create a `README.md` with project description, installation, usage, and API details.

**AI Prompt**:
```
You are a TDD expert documenting the `usbX` microservice. Analyze the requirement to create a `README.md` with project description, installation steps, usage examples, and API details. The smallest testable unit is verifying the file exists and contains key sections. Write a failing test (e.g., a shell script that checks for `README.md` and required sections). Provide minimal content for `README.md`. Refactor to include example curl commands and limitations. Output the test, code, and refactoring notes.
```

---

#### Step 27: Create systemd Service File
**Requirement**: Create a systemd service file to run `usbx` as a daemon.

**AI Prompt**:
```
You are a TDD expert creating a systemd service for the `usbX` microservice. Analyze the requirement to create a `/etc/systemd/system/usbx.service` file that runs `usbx` as a daemon. The smallest testable unit is enabling and starting the service without errors. Write a failing test (e.g., a shell script that checks if the service starts). Provide minimal code for `usbx.service`. Refactor to include proper user permissions and logging. Output the test, code, and refactoring notes.
```

---

#### Step 28: Commit to GitHub
**Requirement**: Commit all files to a GitHub repository with a `.gitignore` and license.

**AI Prompt**:
```
You are a TDD expert managing the GitHub repository for the `usbX` microservice. Analyze the requirement to commit all files, including a `.gitignore` and MIT License. The smallest testable unit is verifying the repository contains all required files. Write a failing test (e.g., a shell script that clones the repo and checks file presence). Provide minimal code for `.gitignore` and `LICENSE`. Refactor to ensure a proper commit message and repo description. Output the test, code, and refactoring notes.
```

---

#### Step 29: Containerize with Docker
**Requirement**: Create a `Dockerfile` to build and run `usbx` with USB passthrough.

**AI Prompt**:
```
You are a TDD expert containerizing the `usbX` microservice. Analyze the requirement to create a `Dockerfile` that builds `usbx` on Ubuntu 22.04 and runs with USB passthrough. The smallest testable unit is building the Docker image and running it to respond on port 8080. Write a failing test (e.g., a shell script that builds the image and tests `/health` with curl). Provide minimal code for the `Dockerfile`. Refactor to run as a non-root user and handle USB permissions. Output the test, code, and refactoring notes.
```

---

#### Step 30: Implement Async Transfer Support
**Requirement**: Implement async USB transfers for the `/handles/{id}/control` endpoint using `libusb_submit_transfer`.

**AI Prompt**:
```
You are a TDD expert implementing async USB transfers for the `usbX` microservice. Analyze the requirement to support async control transfers in `/handles/{id}/control` using `libusb_submit_transfer` and a callback. The smallest testable unit is submitting an async transfer and verifying the callback is triggered. Write a failing test (e.g., a C unit test that mocks a transfer and checks callback execution). Provide minimal code for the endpoint with an `AsyncTransfer` struct and callback. Refactor to manage a thread-safe pending transfer list. Output the test, code, and refactoring notes.
```

---

#### Step 31: Implement Hotplug Callback
**Requirement**: Implement USB hotplug event handling using `libusb_hotplug_register_callback`.

**AI Prompt**:
```
You are a TDD expert implementing USB hotplug support for the `usbX` microservice. Analyze the requirement to register a hotplug callback for device arrival/removal using `libusb_hotplug_register_callback`. The smallest testable unit is registering the callback and verifying it logs an event. Write a failing test (e.g., a C unit test that mocks a hotplug event and checks log output). Provide minimal code for the callback and registration. Refactor to handle handle cleanup on device removal. Output the test, code, and refactoring notes.
```

---

#### Step 32: Implement Syslog Logging
**Requirement**: Replace file-based logging with syslog integration.

**AI Prompt**:
```
You are a TDD expert implementing syslog logging for the `usbX` microservice. Analyze the requirement to replace file-based logging with `syslog` using `openlog` and `vsyslog`. The smallest testable unit is logging an error message to syslog. Write a failing test (e.g., a C unit test that calls `log_error` and checks syslog output). Provide minimal code for `log_init`, `log_error`, and `log_info`. Refactor to ensure compatibility with systemd and add dual stderr logging. Output the test, code, and refactoring notes.
```

---

#### Step 33: Enhance /health Endpoint with Metrics
**Requirement**: Enhance the `/health` endpoint to include open handle count.

**AI Prompt**:
```
You are a TDD expert enhancing the GET /health endpoint for the `usbX` microservice. Analyze the requirement to add the count of open handles to the JSON response using `HASH_COUNT`. The smallest testable unit is returning the correct handle count in the response. Write a failing test (e.g., a C unit test that adds handles and checks the JSON response). Provide minimal code to update the endpoint with `HASH_COUNT`. Refactor to ensure thread safety and add more metrics if needed. Output the test, code, and refactoring notes.
```

---

#### Step 34: Add Performance Profiling
**Requirement**: Add profiling support using `perf` to identify bottlenecks.

**AI Prompt**:
```
You are a TDD expert adding performance profiling for the `usbX` microservice. Analyze the requirement to profile the application using `perf` to measure endpoint response times. The smallest testable unit is running `perf record` and generating a report without errors. Write a failing test (e.g., a shell script that runs `perf` and checks for a report file). Provide minimal documentation for running `perf record` and `perf report`. Refactor to include profiling instructions in `README.md`. Output the test, code, and refactoring notes.
```

---

#### Step 35: Add Concurrency Stress Testing
**Requirement**: Add a stress test to verify concurrency handling with multiple simultaneous requests.

**AI Prompt**:
```
You are a TDD expert implementing concurrency stress testing for the `usbX` microservice. Analyze the requirement to test multiple simultaneous requests using `ab` (Apache Benchmark). The smallest testable unit is verifying the server handles 10 concurrent requests to `/devices` without crashing. Write a failing test (e.g., a shell script that runs `ab` and checks for successful responses). Provide minimal documentation for running `ab`. Refactor to include connection limits in `MHD_start_daemon`. Output the test, code, and refactoring notes.
```

---

### Notes on Approach
- **Granularity**: The steps are broken into small, testable units to ensure each can be developed independently with clear tests. For example, handle management functions (`add_handle`, `find_handle`, etc.) are separate steps to allow focused testing.
- **Dependencies**: Steps build on each other, referencing prior code (e.g., `add_handle` uses `HandleEntry` from Step 4). The AI prompts assume access to previous steps’ code.
- **Testing Framework**: C unit tests use the Check framework (as suggested in step8.md) for internal functions, while shell scripts with `curl` test HTTP endpoints. This aligns with the provided testing strategies.
- **Refactoring**: Each prompt includes refactoring to improve robustness, add logging, or optimize performance, as per the TDD cycle.
- **Advanced Features**: Async transfers, hotplug, and syslog are placed later to ensure core functionality is stable first.
- **Error Handling and Security**: Integrated throughout (e.g., Steps 21–24) to align with step7.md’s focus on production readiness.
- **Deployment**: Steps 26–29 cover documentation and deployment, ensuring the project is complete and deployable.

### Additional Considerations
- **Testing Environment**: Some tests (e.g., USB device interactions) require physical devices or mocks. The prompts suggest mocking where possible (e.g., for `libusb_get_device_list` or hotplug events) to ensure CI compatibility.
- **Scalability**: Steps like connection limits (Step 24) and stress testing (Step 35) ensure the microservice handles production loads.
- **Documentation**: README and systemd steps (26–27) ensure usability and deployment clarity, as per step9.md.
- **Extensibility**: Async and hotplug steps (30–31) cover step10.md’s extensions, keeping them optional but well-tested.

If you need the full implementation details for any specific step (e.g., test code, implementation, or refactoring), let me know, and I can expand a particular prompt with complete code. Alternatively, I can generate a subset of steps with full test and code details to demonstrate the TDD process. Let me know your preference!
