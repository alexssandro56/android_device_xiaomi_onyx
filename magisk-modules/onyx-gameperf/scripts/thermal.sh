#!/system/bin/sh
# ===========================================================================
# thermal.sh [get|default|cool|set N] - Xiaomi thermal profile control.
#
# Writes to the device's own thermal node /sys/class/thermal/thermal_message/
# sconfig (confirmed present on onyx). SAFE DESIGN:
#   default -> sconfig=0  (verified "normal" profile) + powersave off
#   cool    -> powersave_mode=1 (MORE conservative = cooler; never less)
#   set N   -> advanced: write a sconfig scene the user trusts (with warning)
#
# We deliberately DO NOT ship a throttle-disabling value: the onyx thermal
# scene map is in a vendor blob and a wrong value could overheat the phone.
# ===========================================================================
DIR=${0%/*}
. "$DIR/common.sh" 2>/dev/null

NODE=/sys/class/thermal/thermal_message/sconfig
PSAVE=/sys/class/thermal/power_save/powersave_mode

case "${1:-get}" in
    get)
        cat "$NODE" 2>/dev/null
        ;;
    default)
        echo 0 > "$NODE"  2>/dev/null
        echo 0 > "$PSAVE" 2>/dev/null
        log "thermal: default (sconfig=0, powersave=0)"
        echo "Perfil térmico: Padrão (sconfig=0)."
        ;;
    cool)
        echo 1 > "$PSAVE" 2>/dev/null
        log "thermal: cool (powersave=1)"
        echo "Perfil térmico: Resfriar (mais conservador, esquenta menos)."
        ;;
    set)
        v="$2"
        case "$v" in ''|*[!0-9]*) echo "ERR: valor inválido (só número)"; exit 1 ;; esac
        echo "$v" > "$NODE" 2>/dev/null
        log "thermal: sconfig=$v (custom)"
        echo "sconfig definido para $v. Se o aparelho esquentar, volte pro Padrão."
        ;;
    *)
        echo "uso: thermal.sh [get|default|cool|set N]"
        exit 1
        ;;
esac
