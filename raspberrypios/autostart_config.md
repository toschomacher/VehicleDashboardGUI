# Raspberry Pi Auto-Start Configuration for Qt6 Vehicle Dashboard

## Overview

This guide explains how to configure **Raspberry Pi OS** to automatically start a Qt6 GUI application on boot using `systemd`.

This method ensures:

* Automatic startup after boot
* Controlled startup timing
* Stability and recovery (optional restart)
* Independence from network delays

---

## Prerequisites

* Raspberry Pi running Raspberry Pi OS
* Qt6 application built and working
* Executable path known (example used in this guide):

```bash
/home/nepal/PiGuiTest/SecondTestGUI/build/appVehicleDashboardGUI
```

---

## Step 1 — Create a systemd Service File

Open a new service file:

```bash
sudo nano /etc/systemd/system/dashboard.service
```

---

## Step 2 — Add Configuration

Paste the following configuration:

```ini
[Unit]
Description=Vehicle Dashboard GUI
After=graphical.target sound.target

[Service]
User=nepal

# Required for GUI apps using desktop (X11)
Environment=DISPLAY=:0
Environment=QT_QPA_PLATFORM=xcb

# Delay startup to avoid race conditions (audio, display, drivers)
ExecStartPre=/bin/sleep 3

# Main application
ExecStart=/home/nepal/PiGuiTest/SecondTestGUI/build/appVehicleDashboardGUI

# Restart only if the app crashes
Restart=on-failure

[Install]
WantedBy=graphical.target
```

---

## Explanation of Configuration

### `[Unit]` Section

```ini
After=graphical.target sound.target
```

* Ensures the application starts **after the desktop environment is ready**
* Also waits for **audio system initialisation**
* Prevents startup delays caused by network dependencies

---

### `[Service]` Section

#### User

```ini
User=nepal
```

* Runs the application as the specified user
* Required for GUI and hardware access

---

#### Display Environment

```ini
Environment=DISPLAY=:0
Environment=QT_QPA_PLATFORM=xcb
```

* `DISPLAY=:0` → connects to the main desktop display
* `QT_QPA_PLATFORM=xcb` → uses X11 (desktop mode)

---

#### Startup Delay

```ini
ExecStartPre=/bin/sleep 3
```

* Adds a delay before launching the app
* Prevents **race conditions** where:

  * audio is not ready
  * GPU/display not initialised
* Typical delay: **2–4 seconds**

---

#### Application Launch

```ini
ExecStart=/home/nepal/PiGuiTest/SecondTestGUI/build/appVehicleDashboardGUI
```

* Full path to your compiled Qt application

---

#### Restart Policy

```ini
Restart=on-failure
```

* Restarts the app only if it crashes
* Prevents infinite restart loops during development

---

### `[Install]` Section

```ini
WantedBy=graphical.target
```

* Starts the service when the system reaches **desktop mode**
* Ensures correct startup timing for GUI apps

---

## Step 3 — Enable the Service

Reload systemd:

```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
```

Enable auto-start:

```bash
sudo systemctl enable dashboard.service
```

---

## Step 4 — Start the Service Manually (Optional)

```bash
sudo systemctl start dashboard.service
```

---

## Step 5 — Check Status

```bash
systemctl status dashboard.service
```

Example output:

```
Active: active (running)
```

---

## View Logs

```bash
journalctl -u dashboard.service -b
```

Useful for debugging:

* startup delays
* Qt errors
* audio issues

---

## Testing

Reboot the system:

```bash
sudo reboot
```

Expected behaviour:

* OS boots normally
* After ~3 seconds delay
* GUI application launches automatically

---

## Common Issues & Fixes

### GUI not appearing

* Check `DISPLAY=:0`
* Ensure desktop environment is enabled

---

### Sound not working

* Ensure `sound.target` is included
* Verify speaker output works manually

---

### Slow startup

* Remove `network.target` dependency if present
* Reduce `sleep` delay

---

### App exits immediately

Check logs:

```bash
journalctl -u dashboard.service -b
```

---

## Optional Improvements

### Faster Boot (No Desktop)

Use fullscreen embedded mode:

```ini
Environment=QT_QPA_PLATFORM=eglfs
```

* Runs directly on GPU
* No desktop required
* Faster startup (automotive-style)

---

### Always Restart (Production Mode)

```ini
Restart=always
RestartSec=2
```

* Automatically recovers from crashes
* Recommended for final deployment

---

## Summary

This configuration:

* Starts the Qt GUI automatically on boot
* Avoids dependency on network availability
* Introduces a controlled delay to prevent hardware race conditions
* Provides a stable and production-ready startup mechanism

---

## Notes for Embedded Systems

In automotive or embedded environments:

* deterministic startup timing is critical
* services should not depend on network availability
* hardware (audio/display) must be initialised before application launch

This systemd-based approach satisfies these requirements.
