#!/system/bin/sh
# ===========================================================================
# service.sh - late_start service. Waits for boot, then applies tweaks.
# ===========================================================================
MODDIR=${0%/*}

while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done
# Let package manager / game service settle.
sleep 25

sh "$MODDIR/scripts/apply-tweaks.sh" >/dev/null 2>&1
