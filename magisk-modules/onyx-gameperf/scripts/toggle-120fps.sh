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

case "$action" in
    on)
        : > "$FLAG_120"
        log "120fps spoof: ENABLED (reboot required)"
        echo "ON"
        echo "Spoof de 120 FPS ATIVADO (experimental). Reinicie o aparelho."
        echo "AVISO: pode nao funcionar e pode quebrar apps de banco/Play Integrity."
        ;;
    off)
        rm -f "$FLAG_120"
        log "120fps spoof: DISABLED (reboot required)"
        echo "OFF"
        echo "Spoof de 120 FPS DESATIVADO. Reinicie o aparelho."
        ;;
    status|*)
        if [ -f "$FLAG_120" ]; then echo "ON"; else echo "OFF"; fi
        ;;
esac
exit 0
