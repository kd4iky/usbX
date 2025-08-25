### Implement HTTP Server

The provided step outlines the core components for setting up an HTTP server using libmicrohttpd and integrating it with libusb event handling. However, it can be expanded with detailed code snippets, explanations of key libmicrohttpd options, error handling, and considerations for request processing to make it more actionable and robust. This expansion will ensure the HTTP server is production-ready, modular, and easier to implement for a C programmer. Below is the expanded version:

- **Include Required Headers for the HTTP Server**:
  - In `src/main.c`, ensure the necessary headers are included for libmicrohttpd and threading, as previously set up:
    ```c
    #include <microhttpd.h> // For HTTP server functionality
    #include <pthread.h>    // For background thread
    #include <unistd.h>     // For usleep
    ```
    - These headers support the HTTP daemon, threading for event handling, and timing functions. The existing includes (`libusb-1.0/libusb.h`, `json-c/json.h`, `uthash.h`, etc.) from prior steps remain.

- **Define the Event Handler Thread for libusb**:
  - Create a background thread to handle libusb events, as libusb requires periodic calls to `libusb_handle_events` to process asynchronous operations or timeouts, even for synchronous transfers.
  - Add the event handler function above `main` in `main.c`:
    ```c
    void *event_handler(void *arg) {
        (void)arg; // Unused
        while (1) {
            int ret = libusb_handle_events(ctx); // Process libusb events
            if (ret != LIBUSB_SUCCESS && ret != LIBUSB_ERROR_INTERRUPTED) {
                fprintf(stderr, "Event handler error: %s\n", libusb_error_name(ret));
                break; // Handle gracefully in production
            }
            usleep(100000); // Sleep 100ms to avoid CPU hogging
        }
        return NULL;
    }
    ```
    - Explanation:
      - `libusb_handle_events(ctx)` processes USB events (e.g., completions, hotplug events). It’s safe to call repeatedly, even with no pending events.
      - The `usleep(100000)` (100ms) balances responsiveness and CPU usage. Adjust based on performance needs (e.g., 10ms for high-frequency devices).
      - Error checking ensures the thread doesn’t silently fail. In production, you might log to a file or signal the main thread to exit.
  - Start the thread in `main` after `libusb_init`:
    ```c
    if (pthread_create(&event_thread, NULL, event_handler, NULL) != 0) {
        fprintf(stderr, "Failed to create event thread\n");
        libusb_exit(ctx);
        return EXIT_FAILURE;
    }
    ```
    - This ensures libusb events are processed without blocking the HTTP server.

- **Start the libmicrohttpd Daemon**:
  - In `main`, after libusb initialization and the event thread, initialize the HTTP server:
    ```c
    struct MHD_Daemon *daemon = MHD_start_daemon(
        MHD_USE_THREAD_PER_CONNECTION | MHD_USE_INTERNAL_POLLING | MHD_USE_ERROR_LOG,
        PORT,
        NULL, NULL, // No connection callback or argument
        &request_handler, NULL, // Handler function and its argument
        MHD_OPTION_END // End of options
    );
    if (!daemon) {
        fprintf(stderr, "Failed to start HTTP daemon\n");
        libusb_exit(ctx);
        return EXIT_FAILURE;
    }
    ```
    - Explanation of options:
      - `MHD_USE_THREAD_PER_CONNECTION`: Each client connection gets its own thread, simplifying concurrent request handling. Suitable for low-to-moderate traffic (e.g., <100 simultaneous clients). For high traffic, consider `MHD_USE_EPOLL` on Linux for scalability, but it’s more complex.
      - `MHD_USE_INTERNAL_POLLING`: Lets libmicrohttpd manage its own event loop, compatible with the threaded model.
      - `MHD_USE_ERROR_LOG`: Enables internal logging to stderr for debugging (e.g., malformed requests).
      - `PORT` (e.g., 8080): Defined as a macro or later made configurable via a config file or env variable (e.g., `getenv("USBX_PORT")`).
    - Add cleanup in `main` before `libusb_exit`:
      ```c
      MHD_stop_daemon(daemon);
      ```

- **Define the Request Handler Callback**:
  - Create a skeleton for the `request_handler` function to process incoming HTTP requests. This is where URL routing and method handling occur:
    ```c
    enum MHD_Result request_handler(void *cls, struct MHD_Connection *connection,
                                   const char *url, const char *method,
                                   const char *version, const char *upload_data,
                                   size_t *upload_data_size, void **con_cls) {
        (void)cls; (void)version; // Unused for now
        struct MHD_Response *response;
        enum MHD_Result ret;
        char *response_str;

        // Initialize connection state on first call
        if (*con_cls == NULL) {
            *con_cls = malloc(sizeof(int)); // Example: store request state
            if (*con_cls == NULL) return MHD_NO;
            *(int*)*con_cls = 0; // Initial state
            return MHD_YES; // Tell MHD to call again for data
        }

        // Handle GET /devices
        if (strcmp(method, "GET") == 0 && strcmp(url, "/devices") == 0) {
            // Placeholder: Will implement in later steps
            response_str = strdup("{\"devices\": []}");
            response = MHD_create_response_from_buffer(
                strlen(response_str), response_str, MHD_RESPMEM_MUST_FREE);
            ret = MHD_queue_response(connection, MHD_HTTP_OK, response);
            MHD_destroy_response(response);
            return ret;
        }

        // Handle POST (e.g., /open, /handles/{id}/control)
        if (strcmp(method, "POST") == 0) {
            if (*upload_data_size != 0) {
                // Buffer POST data (to be parsed as JSON later)
                // Placeholder: Store in *con_cls or process directly
                *upload_data_size = 0; // Indicate data consumed
                return MHD_YES;
            }
            // Process completed POST (implement in later steps)
            response_str = strdup("{\"status\": \"not_implemented\"}");
            response = MHD_create_response_from_buffer(
                strlen(response_str), response_str, MHD_RESPMEM_MUST_FREE);
            ret = MHD_queue_response(connection, MHD_HTTP_NOT_IMPLEMENTED, response);
            MHD_destroy_response(response);
            return ret;
        }

        // Handle unknown routes
        response_str = strdup("{\"error\": \"Not Found\"}");
        response = MHD_create_response_from_buffer(
            strlen(response_str), response_str, MHD_RESPMEM_MUST_FREE);
        ret = MHD_queue_response(connection, MHD_HTTP_NOT_FOUND, response);
        MHD_destroy_response(response);
        return ret;
    }
    ```
    - Explanation:
      - The `request_handler` is called by libmicrohttpd for each request, providing the URL, method, and POST data (if any).
      - `*con_cls` is used to maintain state across multiple calls for a single request (e.g., for chunked POST data). Here, a simple `int` is allocated as a placeholder; later steps will use it for buffering JSON.
      - Responses use `MHD_create_response_from_buffer` with `MHD_RESPMEM_MUST_FREE` to let libmicrohttpd free the response string, preventing leaks.
      - This skeleton handles GET /devices and POST generically; later steps will flesh out specific endpoints (e.g., parsing JSON, calling libusb functions).
      - Returns `MHD_YES` to continue processing (e.g., for more POST data) or `MHD_NO` on errors.

- **Integrate with Main Function**:
  - Update the `main` function to include both the event thread and HTTP server, ensuring proper initialization and cleanup:
    ```c
    int main() {
        int ret;

        // Initialize libusb
        ret = libusb_init(&ctx);
        if (ret < 0) {
            fprintf(stderr, "Failed to initialize libusb: %s\n", libusb_error_name(ret));
            return EXIT_FAILURE;
        }

        // Start libusb event thread
        if (pthread_create(&event_thread, NULL, event_handler, NULL) != 0) {
            fprintf(stderr, "Failed to create event thread\n");
            libusb_exit(ctx);
            return EXIT_FAILURE;
        }

        // Start HTTP daemon
        struct MHD_Daemon *daemon = MHD_start_daemon(
            MHD_USE_THREAD_PER_CONNECTION | MHD_USE_INTERNAL_POLLING | MHD_USE_ERROR_LOG,
            PORT, NULL, NULL, &request_handler, NULL, MHD_OPTION_END);
        if (!daemon) {
            fprintf(stderr, "Failed to start HTTP daemon\n");
            libusb_exit(ctx);
            return EXIT_FAILURE;
        }

        // Keep running (for testing; replace with signal handling in production)
        printf("Server running on port %d. Press Enter to stop...\n", PORT);
        getchar();

        // Cleanup
        MHD_stop_daemon(daemon);
        libusb_exit(ctx);
        return EXIT_SUCCESS;
    }
    ```
    - This ties together the libusb context, event thread, and HTTP server. The `getchar()` is a simple way to keep the server running for testing; in production, use a signal handler (e.g., SIGINT) for graceful shutdown.

- **Additional Considerations and Best Practices**:
  - **Thread Safety**: The event thread and HTTP threads access the libusb context concurrently. Libusb is thread-safe with a single context, but the `handles` hash map (from earlier steps) requires mutex protection (handled in later steps).
  - **Error Handling**: Added checks for `pthread_create` and `MHD_start_daemon`. Expand with logging (e.g., to a file or syslog) in production.
  - **Scalability**: `MHD_USE_THREAD_PER_CONNECTION` is simple but not ideal for thousands of connections. For high load, consider `MHD_USE_EPOLL` or a thread pool (`MHD_USE_THREAD_POOL`), but test performance first.
  - **Testing**: After compiling (`make`), test with `curl http://localhost:8080/devices`. It should return `{"devices": []}`. Later steps will implement actual device enumeration.
  - **Permissions**: Ensure the process has USB access (e.g., run as a user in the `plugdev` group or adjust udev rules for `/dev/bus/usb`).
  - **Modularity**: Consider moving `request_handler` to a separate `src/handlers.c` file if it grows large, but keep it in `main.c` for now to minimize complexity.

- **Potential Improvements**:
  - Add `MHD_OPTION_CONNECTION_LIMIT` to cap concurrent connections (e.g., 100) to prevent resource exhaustion.
  - Use `MHD_OPTION_NOTIFY_CONNECTION` for IP-based access control (e.g., restrict to localhost).
  - Implement a signal handler (e.g., for SIGINT) to stop the daemon gracefully:
    ```c
    #include <signal.h>
    volatile sig_atomic_t keep_running = 1;
    void signal_handler(int sig) { keep_running = 0; }
    // In main: signal(SIGINT, signal_handler); then replace getchar() with while (keep_running) pause();
    ```

This expanded step provides a working HTTP server skeleton with detailed code, explanations, and considerations for robustness. It’s more comprehensive than the original but remains focused on immediate implementation. If you need further details (e.g., splitting into multiple files or specific endpoint logic), let me know!
