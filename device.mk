#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Use scudo
PRODUCT_USE_SCUDO := true

# Generic ramdisk allow list
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_ramdisk.mk)

# Project ID Quota
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# pKVM
$(call inherit-product, packages/modules/Virtualization/apex/product_packages.mk)

# Vendor
$(call inherit-product, vendor/xiaomi/onyx/onyx-vendor.mk)

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH) \
    hardware/xiaomi

# Platform
TARGET_BOARD_PLATFORM := sun

# Reduce system server verbosity
PRODUCT_SYSTEM_SERVER_DEBUG_INFO := false

# A/B
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/vabc_features.mk)
PRODUCT_VIRTUAL_AB_COMPRESSION_METHOD := lz4
PRODUCT_VENDOR_PROPERTIES += ro.virtual_ab.compression.threads=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=erofs \
    POSTINSTALL_OPTIONAL_vendor=true

PRODUCT_PACKAGES += \
    checkpoint_gc \
    otapreopt_script

# AAPT
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxhdpi

# API
BOARD_SHIPPING_API_LEVEL := 202404
PRODUCT_SHIPPING_API_LEVEL := 35

# Audio
TARGET_USE_AIDL_QTI_BT_AUDIO := true

PRODUCT_PACKAGES += \
    android.hardware.audio.common-V1-ndk.vendor \
    android.hardware.audio.core-V2-ndk.vendor \
    android.hardware.audio.core.sounddose-V1-ndk.vendor \
    libalsautilsv2.vendor \
    libaudioaidlcommon.vendor \
    libaudioutils_shim \
    libmemunreachable.vendor \
    qti-audio-types-aidl-V1-ndk.vendor

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/audio/audio_effects_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_tuna/audio_effects_config.xml \
    $(LOCAL_PATH)/configs/audio/audio_module_config_primary.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/audio_module_config_primary.xml \
    $(LOCAL_PATH)/configs/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_tuna/audio_policy_configuration.xml

# Boot control
PRODUCT_PACKAGES += \
    android.hardware.boot-service.qti \
    android.hardware.boot-service.qti.recovery

# Camera
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.ar.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.ar.xml \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.full.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.full.xml \
    frameworks/native/data/etc/android.hardware.camera.raw.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.raw.xml

# Characteristics
PRODUCT_CHARACTERISTICS := nosdcard

# DRM
PRODUCT_PACKAGES += \
    android.hardware.drm-service.clearkey

# Dalvik
PRODUCT_VENDOR_PROPERTIES += \
    dalvik.vm.heapstartsize=24m \
    dalvik.vm.heapgrowthlimit=512m \
    dalvik.vm.heapsize=512m \
    dalvik.vm.heaptargetutilization=0.5 \
    dalvik.vm.heapminfree=8m \
    dalvik.vm.heapmaxfree=96m \
    dalvik.vm.enable_time_based_gc_trigger=true \
    dalvik.vm.jitmaxsize=256m \
    dalvik.vm.jitinitialsize=32m \
    dalvik.vm.parallel-image-loading=true \
    dalvik.vm.madvise.vdexfile.size=209715200 \
    dalvik.vm.madvise.odexfile.size=209715200 \
    dalvik.vm.usap_pool_enabled=true \
    dalvik.vm.usap_pool_size_max=5

# Enable whole-program R8 Java optimizations for SystemUI and system_server,
# but also allow explicit overriding for testing and development.
SYSTEM_OPTIMIZE_JAVA := true
SYSTEMUI_OPTIMIZE_JAVA := true

# Dolby
PRODUCT_PACKAGES += \
    LunarisDolby

# Fastbootd
PRODUCT_PACKAGES += \
    android.hardware.fastboot-service.example_recovery \
    fastbootd

# Fingerprint
$(call soong_config_set,XIAOMI_BIOMETRICS_FINGERPRINT,IMPL_VER,V2)
PRODUCT_PACKAGES += \
    android.hardware.biometrics.fingerprint-service.xiaomi \
    libudfpshandler

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml

# Graphics
TARGET_USES_VULKAN = true

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute-0.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level-1.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version-1_1.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_3.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version-1_3.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2024-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.software.opengles.deqp.level-2024-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.opengles.deqp.level.xml

PRODUCT_PACKAGES += \
    ANGLE

# GMS
ifeq ($(WITH_GMS),true)
    $(call inherit-product-if-exists, vendor/gms/products/gms.mk)
endif

# Hypsy
PRODUCT_PACKAGES += \
    xiaomi.system.hypsys.common-service

# Health
$(call inherit-product, vendor/qcom/opensource/healthd-ext/health-vendor-product.mk)

# Init
PRODUCT_PACKAGES += \
    fstab.qcom \
    fstab.qcom.vendor_ramdisk \
    init.target.rc \
    init.onyx.overrides.rc \
    init.xiaomi.rc \
    ueventd.xiaomi.rc

# Save boot logs to /metadata/bootlog during bring-up
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_PACKAGES += \
    init.onyx.bootlog.rc
endif

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/init/fstab.qcom:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.qcom \
    $(LOCAL_PATH)/init/init.recovery.qcom.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.qcom.rc

# IR
PRODUCT_PACKAGES += \
    android.hardware.ir-service.xiaomi

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.consumerir.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.consumerir.xml

# Keylayout
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/keylayout/uinput-xiaomi.kl:$(TARGET_COPY_OUT_ODM)/usr/keylayout/uinput-xiaomi.kl

# Keymint
PRODUCT_PACKAGES += \
    android.hardware.authsecret-service.nxp-qti \
    android.hardware.security.keymint-service.strongbox-nxp \
    android.hardware.weaver-service.nxp-qti \
    android.hardware.weaver-service.nxp.xml

PRODUCT_PACKAGES += \
    android.hardware.hardware_keystore_V3.xml

PRODUCT_SOONG_NAMESPACES += \
    hardware/nxp/keymint/generic \
    hardware/nxp/weaver/generic

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/hal_uuid_map.xml:$(TARGET_COPY_OUT_VENDOR)/etc/hal_uuid_map_config.xml \
    $(LOCAL_PATH)/configs/hal_uuid_map.xml:$(TARGET_COPY_OUT_VENDOR)/etc/hal_uuid_map_onyx.xml

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.device_id_attestation.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.device_id_attestation.xml \
    frameworks/native/data/etc/android.hardware.keystore.app_attest_key.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.keystore.app_attest_key.xml \
    frameworks/native/data/etc/android.hardware.strongbox_keystore.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.strongbox_keystore.xml

# Lights
PRODUCT_PACKAGES += \
    android.hardware.light-service.onyx

# Lineage Health
PRODUCT_PACKAGES += \
    vendor.lineage.health-service.default

TARGET_HEALTH_CHARGING_CONTROL_CHARGING_ENABLED := 0
TARGET_HEALTH_CHARGING_CONTROL_CHARGING_DISABLED := 1
TARGET_HEALTH_CHARGING_CONTROL_CHARGING_PATH := /sys/class/xm_power/charger/smart_charge/smart_night
TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_BYPASS := false

# vendor.lineage.health-service.default reads these from the lineage_health
# namespace, but vendor/aospa only exports them as aospaGlobalVars. Without a
# charging path the HAL keeps probing the generic nodes forever and never
# registers, which blocks system_server in HealthInterfaceService.
$(call soong_config_set,lineage_health,charging_control_charging_path,$(TARGET_HEALTH_CHARGING_CONTROL_CHARGING_PATH))
$(call soong_config_set,lineage_health,charging_control_charging_enabled,$(TARGET_HEALTH_CHARGING_CONTROL_CHARGING_ENABLED))
$(call soong_config_set,lineage_health,charging_control_charging_disabled,$(TARGET_HEALTH_CHARGING_CONTROL_CHARGING_DISABLED))
$(call soong_config_set_bool,lineage_health,charging_control_supports_bypass,$(TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_BYPASS))

# Kernel
KERNEL_PREBUILT_DIR := device/xiaomi/onyx-kernel

PRODUCT_ENABLE_UFFD_GC := true

# Media
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/media/media_codecs_tuna_v0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_tuna_v0.xml \
    $(LOCAL_PATH)/configs/media/media_codecs_performance_tuna_v0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_performance_tuna_v0.xml \
    $(LOCAL_PATH)/configs/media/video_system_specs.json:$(TARGET_COPY_OUT_VENDOR)/etc/media_tuna_v0/video_system_specs.json \
    $(LOCAL_PATH)/configs/media/media_profiles_tuna_v0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_tuna_v0.xml

# Memtrack
PRODUCT_PACKAGES += \
    vendor.qti.hardware.memtrack-service

# NFC
PRODUCT_PACKAGES += \
    android.hardware.nfc-service.nxp \
    com.android.nfc_extras

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.nfc.ese.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.nfc.ese.xml \
    frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.nfc.hce.xml \
    frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.nfc.hcef.xml \
    frameworks/native/data/etc/android.hardware.nfc.uicc.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.nfc.uicc.xml \
    frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.nfc.xml \
    frameworks/native/data/etc/android.hardware.se.omapi.ese.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.se.omapi.ese.xml \
    frameworks/native/data/etc/android.hardware.se.omapi.uicc.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.se.omapi.uicc.xml \
    frameworks/native/data/etc/com.android.nfc_extras.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/com.android.nfc_extras.xml \
    frameworks/native/data/etc/com.nxp.mifare.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/com.nxp.mifare.xml

# Overlays
PRODUCT_PACKAGES += \
    ApertureOverlayOnyx \
    CarrierConfigOverlayOnyx \
    DeviceAsWebcamResTarget \
    SystemUIOverlayOnyx \
    AOSPAFrameworkOverlayOnyx \
    FrameworkOverlayOnyx \
    FrameworkOverlayOnyxCN \
    FrameworkOverlayOnyxGL \
    NfcOverlayOnyx \
    SecureElementOverlayOnyx \
    SettingsOverlayOnyx \
    SettingsProviderOverlayOnyx \
    SettingsProviderOverlayOnyxCN \
    WifiOverlayOnyx \
    WifiOverlayOnyxCN

# Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

PRODUCT_PACKAGES += \
    vendor_bt_firmware_mountpoint \
    vendor_dsp_mountpoint \
    vendor_firmware_mnt_mountpoint \
    vendor_modem_firmware_mountpoint

# Properties
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/properties/odm_CN.prop:$(TARGET_COPY_OUT_ODM)/etc/odm_CN.prop \
    $(LOCAL_PATH)/properties/odm_GL.prop:$(TARGET_COPY_OUT_ODM)/etc/odm_GL.prop \
    $(LOCAL_PATH)/properties/odm_IN.prop:$(TARGET_COPY_OUT_ODM)/etc/odm_IN.prop

# QSPA
PRODUCT_PACKAGES += \
    vendor.qti.qspa-service \
    qspa_vendor.rc

# QTI COMPONENTS
TARGET_COMMON_QTI_COMPONENTS := \
    alarm \
    audio \
    av \
    bt \
    display \
    gps \
    init \
    perf \
    telephony \
    usb \
    vibrator \
    wfd \
    wlan \
    overlay

# Parts
PRODUCT_PACKAGES += \
    XiaomiParts

# Parts
PRODUCT_PACKAGES += \
    XiaomiParts

# Perf
PRODUCT_PACKAGES += \
    workloadclassifier-power-allowlist.xml

# device/qcom/common's sun perf config only lists SM8750 (618). Add SM8735
# (tuna: 655, 681, 694) with its own 2+3+2+1 cluster layout. device.mk is
# inherited before aospa-target.mk, so this copy wins.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/perf/targetconfig.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/targetconfig.xml

# Sensors
PRODUCT_PACKAGES += \
    android.frameworks.sensorservice@1.0.vendor \
    android.hardware.sensors-service.xiaomi-multihal \
    sensors.dynamic_sensor_hal \
    sensors.xiaomi

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/sensors/hals.conf:$(TARGET_COPY_OUT_ODM)/etc/sensors/hals.conf

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.dynamic.head_tracker.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.dynamic.head_tracker.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml

# Telephony
PRODUCT_PACKAGES += \
    qcrilNrDb_vendor

PRODUCT_PACKAGES += \
    rfs_msm_mpss_readonly_mbnconfig_symlink

# Thermal
PRODUCT_PACKAGES += \
    android.hardware.thermal-service.qti

# Task Profiles
PRODUCT_COPY_FILES += \
    system/core/libprocessgroup/profiles/task_profiles.json:$(TARGET_COPY_OUT_VENDOR)/etc/task_profiles.json \
    system/core/libprocessgroup/profiles/cgroups.json:$(TARGET_COPY_OUT_VENDOR)/etc/cgroups.json

# Update engine
PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier

# Usb
PRODUCT_HAS_GADGET_HAL := true

ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.usb.config=mtp,adb
endif

# Verified boot
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml

# WiFi
PRODUCT_PACKAGES += \
    firmware_WCNSS_qcom_cfg.ini_symlink-kiwi_v2 \
    firmware_WCNSS_qcom_cfg.ini_symlink-peach \
    firmware_WCNSS_qcom_cfg.ini_symlink-peach_v2 \
    firmware_WCNSS_qcom_cfg.ini_symlink-wcn7750 \
    firmware_WCNSS_qcom_cfg.ini_symlink-qca6750 \
    firmware_wlan_mac.bin_symlink-kiwi_v2 \
    firmware_wlan_mac.bin_symlink-peach \
    firmware_wlan_mac.bin_symlink-peach_v2 \
    firmware_wlan_mac.bin_symlink-wcn7750 \
    firmware_wlan_mac.bin_symlink-qca6750 \
    firmware_wlanmdsp.otaupdate_symlink

# Game Turbo
$(call inherit-product-if-exists, packages/apps/NotGameTurbo/notgameturbo.mk)

# Vendor MiuiCamera
$(call inherit-product-if-exists, device/xiaomi/onyx-miuicamera/device.mk)
