#!/bin/bash

# Hardware xiaomi (fresh clone)
echo "Cloning hardware xiaomi source..."
rm -rf hardware/xiaomi
git clone -b bka https://github.com/sm8635-dev/hardware_xiaomi.git hardware/xiaomi

# Kernel source (fresh clone)
echo "Cloning kernel source tree..."
rm -rf device/xiaomi/onyx-kernel
git clone -b lineage-23.1 https://github.com/AxionAOSP-devices/android_kernel_xiaomi_onyx.git device/xiaomi/onyx-kernel

# Google Camera (fresh clone)
echo "Cloning Google Camera"
rm -rf vendor/xiaomi/GoogleCamera
git clone -b 16 https://github.com/Onyx-Hubs/vendor_xiaomi_GoogleCamera.git vendor/xiaomi/GoogleCamera

# Lunaris Dolby (fresh clone)
echo "Cloning Lunaris Dolby"
rm -rf packages/apps/LunarisDolby
git clone -b 16.0 https://github.com/unmoved21/packages_apps_LunarisDolby.git packages/apps/LunarisDolby

echo "vendorsetup.sh execution complete."
