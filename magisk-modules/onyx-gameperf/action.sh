#!/system/bin/sh
# ===========================================================================
# action.sh - runs when you tap the "Action" button on the module
# (Magisk 26.4+ / KernelSU / APatch). Re-applies all tweaks on demand.
# For a full control panel, open the module's WebUI (KernelSU/APatch/MMRL).
# ===========================================================================
MODDIR=${0%/*}
echo "POCO F7 (onyx) - reaplicando tweaks..."
sh "$MODDIR/scripts/apply-tweaks.sh"
echo ""
echo "Pronto. Abra a WebUI do modulo para mais opcoes."
