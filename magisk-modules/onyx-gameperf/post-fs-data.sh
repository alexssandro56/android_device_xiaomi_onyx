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

# Spoof to a generic recent flagship. This is a best-effort attempt only.
# NOTE: this changes props system-wide and may affect Play Integrity.
$RESETPROP -n ro.product.model          "SM-S928B"     2>/dev/null
$RESETPROP -n ro.product.vendor.model   "SM-S928B"     2>/dev/null
$RESETPROP -n ro.product.system.model   "SM-S928B"     2>/dev/null
$RESETPROP -n ro.product.manufacturer   "samsung"      2>/dev/null
$RESETPROP -n ro.product.vendor.manufacturer "samsung" 2>/dev/null
$RESETPROP -n ro.product.brand          "samsung"      2>/dev/null

log "post-fs-data: 120fps spoof props applied"
exit 0
