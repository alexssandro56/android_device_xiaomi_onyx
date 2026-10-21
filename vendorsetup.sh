# Apply the patches in device/xiaomi/onyx/patches/<project path>/ to the
# matching projects. repo sync drops them, so this runs on every envsetup
# and skips patches that are already applied.
onyx_apply_patches() {
    local top=$(gettop)
    local dir patch project
    for dir in $(find "$top/device/xiaomi/onyx/patches" -name '*.patch' -exec dirname {} \; | sort -u); do
        project=${dir#$top/device/xiaomi/onyx/patches/}
        for patch in "$dir"/*.patch; do
            if git -C "$top/$project" apply --reverse --check "$patch" >/dev/null 2>&1; then
                continue
            fi
            if git -C "$top/$project" -c user.name=onyx -c user.email=onyx@localhost \
                    am -q --3way "$patch"; then
                echo "onyx: applied $(basename "$patch") to $project"
            else
                git -C "$top/$project" am --abort >/dev/null 2>&1
                echo "onyx: failed to apply $(basename "$patch") to $project"
            fi
        done
    done
}
onyx_apply_patches
