### Documentation and Deployment

The provided step outlines the essential tasks for documenting and deploying the `usbX` microservice, including updating the README, creating a systemd service, committing to GitHub, and optional Docker containerization. While it covers the core requirements, it can be expanded with detailed content for the README, a complete systemd service file, specific GitHub repository management steps, a full Dockerfile with USB passthrough instructions, and additional deployment considerations like logging and monitoring. This expansion ensures the microservice is well-documented, easily deployable, and production-ready while remaining clear for a C programmer. Below is the expanded version:

- **Update README.md**:
  - Create or update `README.md` in the repository root to provide comprehensive documentation for users and developers. The README should describe the project, API, usage, setup, and limitations within the 350-character GitHub description limit for the repo summary.
  - Example `README.md` content:
    ```markdown
    # usbX

    A microservice leveraging libusb to connect and interact with USB devices on a local Linux machine. Provides a RESTful API for device enumeration, opening, and data transfers (control, bulk, etc.). Ideal for containerized apps or remote USB management.

    ## Description

    usbX exposes a lightweight HTTP server using libmicrohttpd to manage USB devices via libusb. It supports listing devices, opening them by bus/address or VID/PID, performing USB transfers, and closing handles, all through JSON-based REST endpoints. Designed for Linux, it requires USB permissions (plugdev group).

    ## Installation

    ### Prerequisites
    - Linux (e.g., Ubuntu 22.04+)
    - Dependencies: libusb-1.0, libmicrohttpd, json-c
    - Build tools: gcc, make, pkg-config
    - USB permissions: Add user to plugdev group (`sudo usermod -aG plugdev $USER`)

    ### Setup
    ```bash
    git clone https://github.com/yourusername/usbX.git
    cd usbX
    sudo apt update && sudo apt install libusb-1.0-0-dev libmicrohttpd-dev libjson-c-dev gcc make pkg-config
    wget https://raw.githubusercontent.com/troydhanson/uthash/master/src/uthash.h -O src/uthash.h
    make
    ```

    ## Usage

    Run the microservice:
    ```bash
    ./usbx
    ```

    Test endpoints with curl (use default credentials `admin:usbXpass123`):
    ```bash
    # List devices
    curl -u admin:usbXpass123 http://localhost:8080/devices
    # Open a device
    curl -u admin:usbXpass123 -X POST -d '{"bus":1, "address":2}' http://localhost:8080/open
    # Control transfer
    curl -u admin:usbXpass123 -X POST -d '{"bmRequestType":0x80, "bRequest":6, "wValue":0x0300, "wIndex":0}' http://localhost:8080/handles/1/control
    # Close handle
    curl -u admin:usbXpass123 -X POST http://localhost:8080/handles/1/close
    # Health check
    curl http://localhost:8080/health
    ```

    ## API Endpoints

    - **GET /devices**: List connected USB devices (e.g., `[{"bus":1, "address":2, "vid":1234, "pid":5678, "description":"USB Device"}]`)
    - **POST /open**: Open a device by bus/address or VID/PID (e.g., `{"bus":1, "address":2}` or `{"vid":0x1234, "pid":0x5678}`), returns `{"handle_id": 1}`
    - **POST /handles/{id}/control**: Perform control transfer (e.g., `{"bmRequestType":0x80, "bRequest":6, "wValue":0x0300, "wIndex":0, "data":"base64"}`)
    - **POST /handles/{id}/bulk**: Perform bulk transfer (e.g., `{"endpoint":0x81, "data":"base64", "timeout":1000}`)
    - **POST /handles/{id}/close**: Close a handle (returns `{"status": "closed"}`)
    - **GET /health**: Check service status (returns `{"status": "ok"}`)

    ## Limitations

    - Requires USB permissions (plugdev group or root).
    - Basic auth is hardcoded; use HTTPS for production.
    - No async transfer support (v1); hotplug support is optional.
    - JSON/base64 adds overhead for large transfers.

    ## Deployment

    See below for systemd or Docker deployment.

    ## License

    MIT License (see LICENSE file).
    ```
  - GitHub repo description (within 350 chars):
    ```
    usbX: A Linux microservice using libusb to manage USB devices via a RESTful API. List devices, open by bus/address or VID/PID, perform control/bulk transfers, and close handles. Built with libmicrohttpd and json-c. Requires plugdev group. MIT License.
    ```
    - This is 248 characters, fitting within the limit, and summarizes the project concisely.
  - Additional notes:
    - Include example curl commands for immediate usability.
    - Highlight permissions (plugdev) and security (HTTPS recommendation).
    - Update as features are added (e.g., hotplug, async transfers).

- **Add a systemd Service File for Daemonizing**:
  - Create a systemd service to run `usbx` as a daemon, ensuring it starts automatically and restarts on failure.
  - Create the service file: `sudo nano /etc/systemd/system/usbx.service` with the following content:
    ```ini
    [Unit]
    Description=usbX Microservice for USB Device Management
    After=network.target

    [Service]
    ExecStart=/path/to/usbx
    WorkingDirectory=/path/to/usbx
    Restart=always
    User=usbx
    Group=plugdev
    Environment="USBX_PORT=8080"
    StandardOutput=append:/var/log/usbx.log
    StandardError=append:/var/log/usbx.log

    [Install]
    WantedBy=multi-user.target
    ```
    - Explanation:
      - `ExecStart`: Path to the compiled `usbx` binary (e.g., `/home/user/usbX/usbx`).
      - `WorkingDirectory`: Directory containing the binary.
      - `Restart=always`: Restarts on crashes.
      - `User=usbx`: Run as a dedicated user for security (create with `sudo adduser --system --no-create-home usbx`).
      - `Group=plugdev`: Ensures USB access.
      - `Environment`: Sets port (make `PORT` configurable in `main.c` via `getenv("USBX_PORT")`).
      - `StandardOutput/StandardError`: Logs to `/var/log/usbx.log` (create with `sudo touch /var/log/usbx.log` and `sudo chown usbx:plugdev /var/log/usbx.log`).
  - Enable and start the service:
    ```bash
    sudo systemctl enable usbx
    sudo systemctl start usbx
    sudo systemctl status usbx
    ```
  - Verify logs: `tail -f /var/log/usbx.log`.
  - Troubleshooting:
    - If the service fails, check logs (`journalctl -u usbx`).
    - Ensure the binary path is correct and executable (`chmod +x /path/to/usbx`).
    - Test permissions by running as the `usbx` user: `sudo -u usbx ./usbx`.

- **Commit and Push to GitHub**:
  - Ensure all files are committed, including source code, Makefile, and documentation.
  - Update `.gitignore` to exclude binaries and logs:
    ```gitignore
    *.o
    usbx
    /var/log/usbx.log
    ```
  - Add a license file: Create `LICENSE` with the MIT License:
    ```text
    MIT License

    Copyright (c) 2025 Your Name

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
    ```
  - Commit and push:
    ```bash
    git add .
    git commit -m "Initial implementation with documentation and systemd service"
    git push origin main
    ```
  - Verify on GitHub: Ensure all files (e.g., `src/main.c`, `Makefile`, `README.md`, `LICENSE`, `uthash.h`) are uploaded and the repo description is set.

- **Containerize with Docker**:
  - Create a `Dockerfile` in the repo root:
    ```dockerfile
    FROM ubuntu:22.04

    # Install dependencies
    RUN apt update && apt install -y \
        libusb-1.0-0-dev \
        libmicrohttpd-dev \
        libjson-c-dev \
        gcc \
        make \
        pkg-config \
        curl \
        && rm -rf /var/lib/apt/lists/*

    # Copy source code
    WORKDIR /app
    COPY . .

    # Build
    RUN make

    # Expose port
    EXPOSE 8080

    # Run as non-root user in plugdev group
    RUN useradd -r -G plugdev usbx
    USER usbx

    # Command to run
    CMD ["./usbx"]
    ```
  - Build and run the Docker container:
    ```bash
    docker build -t usbx .
    docker run --rm -p 8080:8080 --device=/dev/bus/usb:/dev/bus/usb usbx
    ```
    - `--device=/dev/bus/usb`: Grants USB access (requires host libusb and udev).
    - `-p 8080:8080`: Maps port 8080.
  - Test in Docker:
    ```bash
    curl http://localhost:8080/health
    ```
  - Troubleshooting:
    - Ensure Docker has USB access: Install libusb on the host and add the user to `plugdev`.
    - If devices aren’t detected, check host udev rules or run with `--privileged` (less secure).
    - Persist logs: Mount a volume, e.g., `-v /path/to/logs:/var/log`.
  - Push to Docker Hub (optional):
    ```bash
    docker tag usbx yourusername/usbx:latest
    docker push yourusername/usbx:latest
    ```

- **Additional Deployment Considerations**:
  - **Logging**: Enhance logging to include request details:
    ```c
    void log_request(const char *method, const char *url, int status_code) {
        log_error("%s %s -> %d", method, url, status_code);
    }
    // In request_handler, after send_json_response:
    log_request(method, url, status_code);
    ```
  - **Monitoring**: Add metrics to `/health` (e.g., `{"open_handles": N}`) by counting hash map entries.
  - **Security**:
    - Deploy behind nginx with HTTPS: Create `nginx.conf`:
      ```nginx
      server {
          listen 443 ssl;
          server_name usbx.example.com;
          ssl_certificate /path/to/cert.pem;
          ssl_certificate_key /path/to/key.pem;
          location / {
              proxy_pass http://localhost:8080;
              proxy_set_header Authorization $http_authorization;
          }
      }
      ```
    - Restrict USB access with udev rules: Create `/etc/udev/rules.d/99-usbx.rules`:
      ```text
      SUBSYSTEM=="usb", GROUP="plugdev", MODE="0660"
      ```
      - Reload: `sudo udevadm control --reload-rules && sudo udevadm trigger`.
  - **Backup and Recovery**: Store logs in `/var/log/usbx.log` and rotate with `logrotate`.
  - **CI/CD**: Extend GitHub Actions (from testing step) to build and push Docker images.

This expanded step provides detailed documentation, a complete systemd service, GitHub management, and a robust Docker setup, making deployment straightforward and secure. It’s significantly more comprehensive than the original while remaining clear for implementation. If you need further details (e.g., nginx config or CI/CD pipeline), let me know!
