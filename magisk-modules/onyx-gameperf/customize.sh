#!/system/bin/sh
# customize.sh - runs at install time on Magisk / KernelSU / APatch.

ui_print "- POCO F7 (onyx) Game & Performance Tweaks"

# Warn (do not block) if this is not an onyx device.
DEV="$(getprop ro.product.device)$(getprop ro.product.vendor.device)"
case "$DEV" in
    *onyx*)
        ui_print "- Device check OK: onyx (POCO F7)"
        ;;
    *)
        ui_print "! Warning: device does not look like 'onyx' (POCO F7)."
        ui_print "! Detected: ${DEV:-unknown}"
        ui_print "! Installing anyway - tweaks are generic and safe,"
        ui_print "! but this module is tuned for the POCO F7."
        ;;
esac

ui_print "- Installing module files"
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/service.sh" 0 0 0755

ui_print "- Done. Reboot to apply."
ui_print "- Tip: in Fortnite set 3D Resolution to 100% and the"
ui_print "  quality preset to High/Epic for the sharpest image."
