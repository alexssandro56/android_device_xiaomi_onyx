#!/system/bin/sh
# status.sh - prints a small JSON status object for the WebUI.
DIR=${0%/*}
. "$DIR/common.sh"
ensure_games_file

device="$(getprop ro.product.device)"
model="$(getprop ro.product.model)"
if [ -f "$FLAG_120" ]; then spoof="on"; else spoof="off"; fi
if pkg_installed "$FORTNITE_PKG"; then fn="installed"; else fn="missing"; fi
games="$(grep -cvE '^\s*(#|$)' "$GAMES_FILE" 2>/dev/null || echo 0)"

printf '{"device":"%s","model":"%s","spoof120":"%s","fortnite":"%s","games":%s}\n' \
    "$device" "$model" "$spoof" "$fn" "$games"
