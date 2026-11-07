#
# SPDX-FileCopyrightText: MIRACLO
# SPDX-License-Identifier: Apache-2.0
#

# Only expose the MIRACLO product when the MIRACLO vendor is present, so this
# file stays inert in the AOSPA/MiraCLO-OS tree (where the product comes from
# vendor/aospa) and never tries to parse vendor/miraclo there.
ifneq ($(wildcard vendor/miraclo),)

PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/miraclo_onyx.mk

COMMON_LUNCH_CHOICES := \
    miraclo_onyx-cp2a-userdebug \
    miraclo_onyx-cp2a-user

endif
