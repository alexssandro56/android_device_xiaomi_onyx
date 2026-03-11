/*
 * Copyright (C) 2024 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <vector>
#include <android-base/properties.h>
#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>

using android::base::GetProperty;

std::vector<std::string> ro_props_default_source_order = {
    "",
    "bootimage.",
    "odm.",
    "odm_dlkm.",
    "product.",
    "system.",
    "system_ext.",
    "vendor.",
    "vendor_dlkm.",
};

void property_override(char const prop[], char const value[], bool add = true) {
    prop_info *pi;
    pi = (prop_info *) __system_property_find(prop);
    if (pi)
        __system_property_update(pi, value, strlen(value));
    else if (add)
        __system_property_add(prop, strlen(prop), value, strlen(value));
}

void set_ro_build_prop(const std::string &prop, const std::string &value) {
    for (const auto &source : ro_props_default_source_order) {
        auto prop_name = "ro." + source + "build." + prop;
        if (source == "")
            property_override(prop_name.c_str(), value.c_str());
        else
            property_override(prop_name.c_str(), value.c_str(), false);
    }
}

void set_ro_product_prop(const std::string &prop, const std::string &value) {
    for (const auto &source : ro_props_default_source_order) {
        auto prop_name = "ro.product." + source + prop;
        property_override(prop_name.c_str(), value.c_str(), false);
    }
}

void vendor_load_properties() {
    std::string region;
    region = GetProperty("ro.boot.hwc", "");

    std::string model;
    std::string brand;
    std::string device;
    std::string fingerprint;
    std::string description;
    std::string marketname;
    std::string mod_device = "onyx_global";

    if (region == "IN") {
        device = "onyx";
        brand = "POCO";
        description = "onyx_in-user 16 BP2A.250605.031.A3 OS3.0.6.0.WOLINXM release-keys";
        fingerprint = "POCO/onyx_in/onyx:16/BP2A.250605.031.A3/OS3.0.6.0.WOLINXM:user/release-keys";
        marketname = "POCO F7";
        model = "25053PC47I";
    } else if (region == "GL") {
        device = "onyx";
        brand = "POCO";
        description = "onyx_global-user 16 BP2A.250605.031.A3 OS3.0.6.0.WOLMIXM release-keys";
        fingerprint = "POCO/onyx_global/onyx:16/BP2A.250605.031.A3/OS3.0.6.0.WOLMIXM:user/release-keys";
        marketname = "POCO F7";
        model = "25053PC47G";
    } else if (region == "CN") {
        device = "onyx";
        brand = "Redmi";
        description = "onyx-user 16 BP2A.250605.031.A3 OS3.0.6.0.WOLCNXM release-keys";
        fingerprint = "Redmi/onyx/onyx:16/BP2A.250605.031.A3/OS3.0.6.0.WOLCNXM:user/release-keys";
        marketname = "REDMI Turbo 4 Pro Edition";
        model = "25053RT47C";
    }

    set_ro_build_prop("fingerprint", fingerprint);
    set_ro_product_prop("brand", brand);
    set_ro_product_prop("device", device);
    set_ro_product_prop("model", model);

    property_override("ro.product.marketname", marketname.c_str());
    property_override("bluetooth.device.default_name", marketname.c_str());
    property_override("vendor.usb.product_string", marketname.c_str());
    property_override("ro.build.description", description.c_str());
    if (!mod_device.empty()) {
        property_override("ro.product.mod_device", mod_device.c_str());
    }
}
