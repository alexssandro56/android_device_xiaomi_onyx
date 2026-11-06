#!/system/bin/sh
# ===========================================================================
# post-fs-data.sh - runs early (before most apps start).
# Only used for the OPTIONAL, experimental 120 FPS device-model spoof.
# Does nothing unless the user explicitly enabled it in the WebUI/action.
# ===========================================================================

MODDIR=${0%/*}
. "$MODDIR/scripts/common.sh"

[ -f "$FLAG_120" ] || exit 0

# resetprop is provided by Magisk/KernelSU in this context.
RESETPROP="$(command -v resetprop || echo resetprop)"

# Target model: read from config (MODEL|BRAND|MANUFACTURER), default S24 Ultra.
MODEL="SM-S928B"; BRAND="samsung"; MANUF="samsung"
MODELF="$CONFIG_DIR/spoof_model.conf"
if [ -f "$MODELF" ]; then
    line="$(cat "$MODELF")"
    m="$(echo "$line" | cut -d'|' -f1)"; b="$(echo "$line" | cut -d'|' -f2)"; u="$(echo "$line" | cut -d'|' -f3)"
    [ -n "$m" ] && MODEL="$m"; [ -n "$b" ] && BRAND="$b"; [ -n "$u" ] && MANUF="$u"
fi

# NOTE: this changes props system-wide and may affect Play Integrity.
$RESETPROP -n ro.product.model               "$MODEL" 2>/dev/null
$RESETPROP -n ro.product.vendor.model        "$MODEL" 2>/dev/null
$RESETPROP -n ro.product.system.model        "$MODEL" 2>/dev/null
$RESETPROP -n ro.product.manufacturer        "$MANUF" 2>/dev/null
$RESETPROP -n ro.product.vendor.manufacturer "$MANUF" 2>/dev/null
$RESETPROP -n ro.product.brand               "$BRAND" 2>/dev/null

log "post-fs-data: model spoof applied ($MODEL / $BRAND)"
exit 0
