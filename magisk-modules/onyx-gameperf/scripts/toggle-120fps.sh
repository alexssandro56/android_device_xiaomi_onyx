#!/system/bin/sh
# ===========================================================================
# toggle-120fps.sh [on|off|status]
# Enables/disables the EXPERIMENTAL device-model spoof that *attempts* to
# expose higher frame-rate options in Fortnite.
#
# HONEST WARNING (read the README): Epic has never officially enabled 120 FPS
# on Android and blocks it server-side. This spoof is UNRELIABLE (usually does
# nothing), VIOLATES Epic's Terms of Service, can break Play Integrity (banking
# apps, Google Wallet) and carries a small but real ban risk. OFF by default.
# Requires a reboot to take effect.
# ===========================================================================

DIR=${0%/*}
. "$DIR/common.sh"

action="${1:-status}"
MODELF="$CONFIG_DIR/spoof_model.conf"   # format: MODEL|BRAND|MANUFACTURER

case "$action" in
    on)
        : > "$FLAG_120"
        log "model spoof: ENABLED (reboot required)"
        echo "ON"
        echo "Spoof de modelo ATIVADO (experimental). Reinicie o aparelho."
        echo "AVISO: global, pode quebrar Play Integrity/banco e nem funcionar."
        ;;
    off)
        rm -f "$FLAG_120"
        log "model spoof: DISABLED (reboot required)"
        echo "OFF"
        echo "Spoof de modelo DESATIVADO. Reinicie o aparelho."
        ;;
    setmodel)
        # $2 = "MODEL|BRAND|MANUFACTURER"
        case "$2" in
            *"|"*"|"*) echo "$2" > "$MODELF"; log "spoof model set: $2"
                       echo "Modelo de spoof salvo. Reinicie para aplicar." ;;
            *) echo "ERR: formato inválido (MODEL|BRAND|MANUFACTURER)"; exit 1 ;;
        esac
        ;;
    getmodel)
        cat "$MODELF" 2>/dev/null || echo "SM-S928B|samsung|samsung"
        ;;
    status|*)
        if [ -f "$FLAG_120" ]; then echo "ON"; else echo "OFF"; fi
        ;;
esac
exit 0
