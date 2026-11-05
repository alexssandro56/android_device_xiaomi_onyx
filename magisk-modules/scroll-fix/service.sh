#!/system/bin/sh
# ===========================================================================
# Scroll Fix (120Hz lock) - POCO F7 (onyx)
# Locks the display refresh rate to 120Hz so scrolling never drops to 60Hz.
# This is the reliable fix for scroll jank on a 120Hz AOSP panel.
#
# Why not override SurfaceFlinger durations (the original module)?
#  - 16.6ms is a 60Hz frame; this panel is 120Hz (8.33ms) -> wrong, adds lag.
#  - 'service call SurfaceFlinger <code>' uses version-specific transaction
#    codes and is a one-shot reset on every refresh-rate change.
#  - The onyx ROM already tunes debug.sf.* durations for 120Hz.
# ===========================================================================

LOG=/data/local/tmp/onyx_scroll_fix.log
: > "$LOG"
log() { echo "[$(date '+%H:%M:%S')] $*" >> "$LOG"; }

until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 2; done
sleep 5

apply() {
    settings put system min_refresh_rate 120  2>/dev/null
    settings put system peak_refresh_rate 120 2>/dev/null
    # Some ROMs also read these float keys:
    settings put system user_refresh_rate 120 2>/dev/null
}

# Apply now, then a couple more times to beat late resets during early boot.
apply; log "locked 120Hz (min=$(settings get system min_refresh_rate) peak=$(settings get system peak_refresh_rate))"
sleep 20; apply
sleep 40; apply
log "done"
