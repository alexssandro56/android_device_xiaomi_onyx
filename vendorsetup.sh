#!/bin/bash

# Hardware xiaomi (fresh clone)
echo "Cloning hardware xiaomi source..."
rm -rf hardware/xiaomi
git clone -b lineage-23.0 https://github.com/Zarathos30/android_hardware_xiaomi.git hardware/xiaomi

# Kernel source (fresh clone)
echo "Cloning kernel source tree..."
rm -rf device/xiaomi/onyx-kernel
git clone -b axion https://github.com/Zarathos30/android_device_xiaomi_onyx-kernel-new.git  device/xiaomi/onyx-kernel

# Google Camera (fresh clone)
echo "Cloning Google Camera"
rm -rf vendor/xiaomi/GoogleCamera
git clone -b 16 https://github.com/Onyx-Hubs/vendor_xiaomi_GoogleCamera.git vendor/xiaomi/GoogleCamera

echo "vendorsetup.sh execution complete."
