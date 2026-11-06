#!/system/bin/sh
# ===========================================================================
# battery.sh [on|off|status] - battery saver that does NOT touch foreground
# performance, so ROM fluidity is unchanged.
#
# It only tunes BACKGROUND / STANDBY behavior:
#   - disable always-on Wi-Fi/Bluetooth background scanning
#   - ensure Doze (deviceidle) is enabled
#   - ensure cached apps are frozen (AOSP default; just makes sure)
# All reversible. Foreground CPU/GPU/refresh are left exactly as-is.
# ===========================================================================
DIR=${0%/*}
. "$DIR/common.sh" 2>/dev/null

FLAG="$CONFIG_DIR/battery_saver.on"

case "${1:-status}" in
    on)
        settings put global ble_scan_always_enabled 0  2>/dev/null
        settings put global wifi_scan_always_enabled 0 2>/dev/null
        settings put global cached_apps_freezer enabled 2>/dev/null
        dumpsys deviceidle enable >/dev/null 2>&1
        : > "$FLAG"
        log "battery saver: ON"
        echo "Economia LIGADA (só segundo plano/standby; fluidez intacta)."
        ;;
    off)
        settings put global ble_scan_always_enabled 1  2>/dev/null
        settings put global wifi_scan_always_enabled 1 2>/dev/null
        rm -f "$FLAG"
        log "battery saver: OFF"
        echo "Economia DESLIGADA (scan de Wi-Fi/BT em segundo plano restaurado)."
        ;;
    status|*)
        [ -f "$FLAG" ] && echo "ON" || echo "OFF"
        ;;
esac
