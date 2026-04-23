#!/bin/bash

echo "===================================="
echo " Vehicle Dashboard Setup Script"
echo "===================================="

# Update system
echo "[1/8] Updating system..."
sudo apt update -y

# Build tools
echo "[2/8] Installing build tools..."
sudo apt install -y build-essential cmake

# Qt6 core
echo "[3/8] Installing Qt6..."
sudo apt install -y qt6-base-dev qt6-declarative-dev qt6-serialbus-dev

# Qt Multimedia (audio)
echo "[4/8] Installing Qt Multimedia..."
sudo apt install -y qml6-module-qtmultimedia

# Audio system
echo "[5/8] Installing audio dependencies..."
sudo apt install -y \
gstreamer1.0-tools \
gstreamer1.0-plugins-base \
gstreamer1.0-plugins-good \
gstreamer1.0-plugins-bad \
gstreamer1.0-plugins-ugly \
alsa-utils

# I2C tools
echo "[6/8] Installing I2C tools..."
sudo apt install -y i2c-tools

# GPIO
echo "[7/8] Installing GPIO tools..."
sudo apt install -y libgpiod-dev gpiod

# CAN utilities
echo "[8/8] Installing CAN tools..."
sudo apt install -y can-utils

echo "===================================="
echo " Installation Complete"
echo "===================================="

echo ""
echo "IMPORTANT:"
echo "- Enable I2C via: sudo raspi-config"
echo "- Configure CAN interface manually"
echo "- Reboot recommended"

# ----------------------------------
# CAN Setup Instructions
# ----------------------------------
echo ""
echo "===================================="
echo " CAN Setup (Manual Step Required)"
echo "===================================="

echo ""
echo "If using CANable in SLCAN mode:"
echo ""
echo "1. Plug in CANable device"
echo "2. Check device:"
echo "   ls /dev/ttyACM*"
echo ""
echo "3. Create CAN interface:"
echo "   sudo slcand -o -c -s6 /dev/ttyACM0 can0"
echo ""
echo "4. Bring interface up:"
echo "   sudo ip link set can0 up"
echo ""
echo "5. Verify:"
echo "   ip link"
echo ""
echo "6. Monitor CAN:"
echo "   candump can0"
echo ""
echo "Expected: CAN messages should appear"
echo ""