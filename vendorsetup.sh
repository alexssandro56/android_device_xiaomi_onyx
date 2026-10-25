# Apply the patches in device/xiaomi/onyx/patches/<project path>/ to the
# matching projects. repo sync drops them, so this runs on every envsetup
# and skips patches that are already applied.
onyx_apply_patches() {
    local top=$(gettop)
    local dir patch project
    for dir in $(find "$top/device/xiaomi/onyx/patches" -name '*.patch' -exec dirname {} \; | sort -u); do
        project=${dir#$top/device/xiaomi/onyx/patches/}
        for patch in "$dir"/*.patch; do
            # A later patch can touch the lines right next to an earlier one, so
            # the reverse check alone misses applied patches: also look for the
            # commit subject in the recent history.
            subject=$(awk '/^Subject: /{s=$0; sub(/^Subject: (\[PATCH[^]]*\] )?/, "", s);
                while ((getline l) > 0 && l ~ /^ /) s = s l; print s; exit}' "$patch")
            if git -C "$top/$project" log -n 300 --format=%s 2>/dev/null | grep -qxF -- "$subject" ||
                    git -C "$top/$project" apply --reverse --check "$patch" >/dev/null 2>&1; then
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
