GPIO Configuration for Shutdown Signal (GPIO 26)
Overview

To enable a reliable hardware-based shutdown mechanism, GPIO pin 26 on the Raspberry Pi was configured with an internal pull-up resistor. This ensures the pin maintains a stable HIGH logic level during normal operation and transitions to LOW when externally connected to ground, allowing it to be used as a shutdown trigger.

Objective

The goal of this configuration was to:

Provide a default stable HIGH state for GPIO 26
Detect a LOW signal when a shutdown condition occurs
Ensure the configuration is applied automatically at system boot
Avoid the need for external pull-up resistors, simplifying hardware design
Implementation Method
1. System Configuration File Modification

The Raspberry Pi boot configuration file was modified to enable the internal pull-up resistor.

Due to the system using a newer Raspberry Pi OS version, the configuration file is located at:
```bash
/boot/firmware/config.txt
```
The file was edited using the following command:

```bash
sudo nano /boot/firmware/config.txt
```
2. GPIO Pull-Up Configuration

The following line was added to the configuration file:

```bash
# Sets pin GPIO26 to use internal pull-up resistor as soon as the Pi boots up
gpio=26=pu
```
Explanation of Configuration
gpio=26=pu
26 → specifies GPIO pin 26
pu → enables the internal pull-up resistor

This configuration ensures:

GPIO 26 defaults to logic HIGH (3.3V)
When connected to ground externally, it reads logic LOW (0V)
3. Applying the Configuration

After saving the changes, the system was rebooted:
```bash
sudo reboot
```
Upon reboot, the Raspberry Pi automatically applies the GPIO configuration during startup.

Operational Behaviour
Condition	GPIO State	Description
No input (idle)	HIGH	Internal pull-up active
Connected to GND	LOW	Shutdown signal triggered