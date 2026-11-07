#
# SPDX-FileCopyrightText: MIRACLO
# SPDX-License-Identifier: Apache-2.0
#

# MIRACLO for the POCO F7 (onyx)

MIRACLO_BUILD := onyx

$(call inherit-product, device/xiaomi/onyx/device.mk)
$(call inherit-product, vendor/miraclo/config/common.mk)

PRODUCT_NAME := miraclo_onyx
PRODUCT_DEVICE := onyx
PRODUCT_BRAND := POCO
PRODUCT_MODEL := POCO F7
PRODUCT_MANUFACTURER := Xiaomi
