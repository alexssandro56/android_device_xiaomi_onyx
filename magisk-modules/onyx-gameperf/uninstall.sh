#!/system/bin/sh
# uninstall.sh - runs when the module is removed. Clears shader/GPU caches so
# apps rebuild them cleanly.
for pat in "*shader*" "*graphitecache*" "*gpucache*"; do
    find /data/user_de/*/*/*cache/* -iname "$pat" -exec rm -rf {} + 2>/dev/null
    find /data/data/* -iname "$pat" -exec rm -rf {} + 2>/dev/null
    find /data_mirror/data*/*/*/*/* -iname "$pat" -exec rm -rf {} + 2>/dev/null
done
rm -rf /data/system/graphicsstats/*/*/* 2>/dev/null
rm -rf /data/resource-cache/*           2>/dev/null
