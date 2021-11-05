/*
 * SPDX-FileCopyrightText: Paranoid Android
 * SPDX-License-Identifier: Apache-2.0
 */

#include <aidl/vendor/aospa/power/BnPowerFeature.h>
#include <android-base/file.h>
#include <android-base/logging.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <cstring>
#include <cstdint>
#include <cerrno>

#define COMMON_DATA_CMD 0
#define SELECT_TOUCH_ID 3
#define SET_CUR_VALUE 0
#define TOUCH_MAGIC 'T'
#define TOUCH_DEV_PATH "/dev/xiaomi-touch"
#define TOUCH_ID 0

enum TouchMode {
    DOUBLE_TAP_MODE = 14,
    SINGLE_TAP_MODE = 11,
};

typedef struct {
    int8_t   touch_id;
    uint8_t  cmd;
    uint16_t mode;
    uint16_t data_len;
    int32_t  data_buf[256];
} common_data_t;

#define TOUCH_IOC_SETMODE _IOWR(TOUCH_MAGIC, COMMON_DATA_CMD, common_data_t)
#define TOUCH_IOC_SETPANEL _IOW(TOUCH_MAGIC, SELECT_TOUCH_ID, int)

namespace aidl {
namespace vendor {
namespace aospa {
namespace power {

static bool sendTouchCommand(TouchMode mode, bool enabled) {
    int fd = open(TOUCH_DEV_PATH, O_RDWR);
    if (fd < 0) {
        LOG(ERROR) << "Failed to open " << TOUCH_DEV_PATH << ": " << strerror(errno);
        return false;
    }

    int touch_id = TOUCH_ID;
    if (ioctl(fd, TOUCH_IOC_SETPANEL, touch_id) < 0) {
        LOG(ERROR) << "Failed to set touch ID: " << strerror(errno);
        close(fd);
        return false;
    }

    common_data_t cmd = {};
    cmd.touch_id = TOUCH_ID;
    cmd.cmd = SET_CUR_VALUE;
    cmd.mode = static_cast<uint16_t>(mode);
    cmd.data_len = 1;
    cmd.data_buf[0] = enabled ? 1 : 0;

    if (ioctl(fd, TOUCH_IOC_SETMODE, &cmd) < 0) {
        LOG(ERROR) << "Failed to send ioctl command: " << strerror(errno);
        close(fd);
        return false;
    }

    close(fd);
    LOG(INFO) << "Successfully set mode " << mode << " to " << (enabled ? "enabled" : "disabled");
    return true;
}

bool setDeviceSpecificFeature(Feature feature, bool enabled) {
    TouchMode mode;

    switch (feature) {
        case Feature::DOUBLE_TAP:
            mode = DOUBLE_TAP_MODE;
            break;
        case Feature::SINGLE_TAP:
            mode = SINGLE_TAP_MODE;
            break;
        default:
            LOG(ERROR) << "Unsupported feature: " << static_cast<int>(feature);
            return false;
    }

    return sendTouchCommand(mode, enabled);
}

}  // namespace power
}  // namespace aospa
}  // namespace vendor
}  // namespace aidl
