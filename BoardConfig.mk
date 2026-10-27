#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/onyx

BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

# A/B
AB_OTA_UPDATER := true

AB_OTA_PARTITIONS := \
    boot \
    dtbo \
    init_boot \
    odm \
    product \
    recovery \
    system \
    system_dlkm \
    system_ext \
    vbmeta \
    vbmeta_system \
    vendor \
    vendor_boot \
    vendor_dlkm

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a-dotprod
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := oryon

# Audio
# The AGM, PAL and audio HALs are built from hardware/qcom-caf/sm8750/audio.

# Board Info
TARGET_BOARD_INFO_FILE := $(DEVICE_PATH)/board-info.txt

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := sun

# Bluetooth
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := $(DEVICE_PATH)/configs/bluetooth/include

# Display
TARGET_SCREEN_DENSITY := 504

# Filesystem
TARGET_FS_CONFIG_GEN += $(DEVICE_PATH)/configs/config.fs

# VINTF
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += \
    $(DEVICE_PATH)/configs/vintf/compatibility_matrix.device.xml

DEVICE_FRAMEWORK_MANIFEST_FILE += $(DEVICE_PATH)/configs/vintf/framework_manifest.xml

DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/configs/vintf/manifest.xml

# Kernel
BOARD_USES_GENERIC_KERNEL_IMAGE := true
TARGET_HAS_GENERIC_KERNEL_HEADERS := true
TARGET_KERNEL_VERSION := 6.6

BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_RAMDISK_USE_LZ4 := true
TARGET_NEEDS_DTBOIMAGE := true

BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_IMAGE_NAME := Image

BOARD_USES_QCOM_MERGE_DTBS_SCRIPT := true

TARGET_KERNEL_SOURCE := kernel/xiaomi/onyx
TARGET_KERNEL_CONFIG := \
    gki_defconfig \
    vendor/custom.config \
    vendor/sun_perf.config \
    vendor/onyx_perf.config

# Link the kernel and its modules with Clang full LTO
KERNEL_LTO := full

BOARD_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)

BOARD_INIT_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_INIT_ARGS += --header_version $(BOARD_INIT_BOOT_HEADER_VERSION)

BOARD_KERNEL_CMDLINE := \
    disable_dma32=on \
    mtdoops.fingerprint=$(AOSPA_VERSION) \
    sysctl.kernel.firmware_config.force_sysfs_fallback=1 \
    video=vfb:640x400,bpp=32,memsize=3072000

# Bring-up debugging, kept out of user builds.
ifneq ($(TARGET_BUILD_VARIANT),user)
# Don't ratelimit userspace writes to kmsg, so init and vendor_modprobe
# logs reach the oops partition (mtdoops).
BOARD_KERNEL_CMDLINE += printk.devkmsg=on

# Reboot into recovery instead of the bootloader when init hits a fatal
# error (first stage mount failure, critical service crash loop), so the
# pstore logs can be pulled over adb.
BOARD_KERNEL_CMDLINE += androidboot.init_fatal_reboot_target=recovery
endif

BOARD_BOOTCONFIG := \
    androidboot.hardware=qcom \
    androidboot.memcg=1 \
    androidboot.serialconsole=0 \
    androidboot.usbcontroller=a600000.dwc3 \
    androidboot.load_modules_parallel=true \
    androidboot.hypervisor.protected_vm.supported=true \
    androidboot.vendor.qspa=true

# Kernel modules
first_stage_modules := $(strip $(shell sed 's/#.*$$//;/^$$/d' $(TARGET_KERNEL_SOURCE)/modules.list.msm.sun $(DEVICE_PATH)/modules/modules.list.first_stage))
second_stage_modules := $(strip $(shell cat $(DEVICE_PATH)/modules/modules.list.second_stage))
vendor_dlkm_modules := $(strip $(shell cat $(DEVICE_PATH)/modules/modules.list.vendor_dlkm))

bzl-modules = $(shell sed -n '$(foreach b,$(1),/^$(b)/,/^]/p;)' $(TARGET_KERNEL_SOURCE)/modules.bzl | sed -n 's,^[[:space:]]*".*/\([^"]*\)".*,\1,p')
gki_modules := $(strip $(call bzl-modules,_COMMON_GKI _ARM64_GKI))
kunit_modules := $(strip $(call bzl-modules,_KUNIT_FRAMEWORK _KUNIT_COMMON _KUNIT_CLK))

BOARD_SYSTEM_KERNEL_MODULES_LOAD := $(gki_modules)
BOARD_VENDOR_KERNEL_MODULES_BLOCKLIST_FILE := $(TARGET_KERNEL_SOURCE)/modules.vendor_blocklist.msm.sun
BOARD_VENDOR_KERNEL_MODULES_LOAD := $(second_stage_modules) $(vendor_dlkm_modules)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_BLOCKLIST_FILE := $(BOARD_VENDOR_KERNEL_MODULES_BLOCKLIST_FILE)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(first_stage_modules)
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(first_stage_modules) $(second_stage_modules)

BOOT_KERNEL_MODULES := $(first_stage_modules) $(second_stage_modules)
SYSTEM_KERNEL_MODULES := $(gki_modules) $(kunit_modules)

TARGET_KERNEL_EXT_MODULE_ROOT := kernel/xiaomi/onyx-modules
TARGET_KERNEL_EXT_MODULES := \
    qcom/opensource/mmrm-driver \
    qcom/opensource/mm-drivers/hw_fence \
    qcom/opensource/mm-drivers/msm_ext_display \
    qcom/opensource/mm-drivers/sync_fence \
    qcom/opensource/audio-kernel \
    qcom/opensource/securemsm-kernel \
    qcom/opensource/synx-kernel \
    qcom/opensource/camera-kernel \
    qcom/opensource/data-kernel/drivers/smem-mailbox \
    qcom/opensource/datarmnet-ext/mem \
    qcom/opensource/dataipa/drivers/platform/msm \
    qcom/opensource/datarmnet/core \
    qcom/opensource/datarmnet-ext/aps \
    qcom/opensource/datarmnet-ext/offload \
    qcom/opensource/datarmnet-ext/perf \
    qcom/opensource/datarmnet-ext/perf_tether \
    qcom/opensource/datarmnet-ext/sch \
    qcom/opensource/datarmnet-ext/shs \
    qcom/opensource/datarmnet-ext/wlan \
    qcom/opensource/display-drivers/msm \
    qcom/opensource/dsp-kernel \
    qcom/opensource/eva-kernel \
    qcom/opensource/graphics-kernel \
    qcom/opensource/spu-kernel \
    qcom/opensource/touch-drivers \
    qcom/opensource/video-driver \
    qcom/opensource/wlan/platform \
    qcom/opensource/wlan/qcacld-3.0/.wcn7750 \
    qcom/opensource/bt-kernel \
    nxp/opensource/driver

# Partitions
BOARD_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_DTBOIMG_PARTITION_SIZE := 25165824
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 104857600
BOARD_SUPER_PARTITION_SIZE := 11811160064
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 100663296

BOARD_FLASH_BLOCK_SIZE := 131072 # (BOARD_KERNEL_PAGESIZE * 64)

BOARD_USES_METADATA_PARTITION := true

BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := odm product system system_dlkm system_ext vendor vendor_dlkm
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 11806965760 # (BOARD_SUPER_PARTITION_SIZE - 4 MiB)
BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions

BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs

BOARD_EROFS_COMPRESS_HINTS := $(DEVICE_PATH)/configs/erofs_compress_hints.txt
BOARD_VENDORIMAGE_EROFS_COMPRESS_HINTS := $(DEVICE_PATH)/configs/erofs_compress_hints.txt
BOARD_ODMIMAGE_EROFS_COMPRESS_HINTS := $(DEVICE_PATH)/configs/erofs_compress_hints.txt

TARGET_COPY_OUT_ODM := odm
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM := system
TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm

# Properties
TARGET_ODM_PROP += $(DEVICE_PATH)/properties/odm.prop
TARGET_PRODUCT_PROP += $(DEVICE_PATH)/properties/product.prop
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/properties/system.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/properties/vendor.prop

# Recovery
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/init/fstab.qcom
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_USERIMAGES_USE_F2FS := true

# RIL
SOONG_CONFIG_rfs_mpss_firmware_symlink_target := modem_firmware

# Sepolicy
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/public
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/private

# Vendor security patch
BOOT_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)

# Verified Boot
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
BOARD_AVB_ALGORITHM := SHA256_RSA2048
BOARD_AVB_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true

BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA2048
BOARD_AVB_BOOT_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 3

BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA2048
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1

BOARD_AVB_VBMETA_SYSTEM := system system_dlkm system_ext product
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2

BOARD_AVB_VENDOR_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_SYSTEM_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_ODM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256

# Game Turbo
-include packages/apps/NotGameTurbo/BoardConfig.mk

# Vendor
include vendor/xiaomi/onyx/BoardConfigVendor.mk

# LeicaCamera (xiaomi-onyx-playground)
-include vendor/xiaomi/onyx-leicacamera/BoardConfigVendor.mk
