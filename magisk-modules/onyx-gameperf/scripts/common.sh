#!/system/bin/sh
# ===========================================================================
# common.sh - shared paths, helpers and the game package list.
# Sourced by apply-tweaks.sh / set-fortnite-lang.sh / toggle-120fps.sh /
# status.sh / service.sh / action.sh.
# ===========================================================================

MODID="onyx_gameperf"
MODDIR="/data/adb/modules/$MODID"
CONFIG_DIR="/data/adb/$MODID"
LOG="$CONFIG_DIR/service.log"
FLAG_120="$CONFIG_DIR/spoof_120fps.on"
GAMES_FILE="$CONFIG_DIR/games.list"
FORTNITE_PKG="com.epicgames.fortnite"

mkdir -p "$CONFIG_DIR" 2>/dev/null

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG"; }

# Default list of games to force (performance mode + no downscale).
# A user-editable copy is written to $GAMES_FILE on first run.
default_games() {
    cat <<'EOF'
com.epicgames.fortnite
com.tencent.ig
com.pubg.imobile
com.pubg.krmobile
com.rekoo.pubgm
com.activision.callofduty.shooter
com.garena.game.codm
com.dts.freefireth
com.dts.freefiremax
com.miHoYo.GenshinImpact
com.miHoYo.Yuanshen
com.HoYoverse.hkrpgoversea
com.miHoYo.hkrpg
com.riotgames.league.wildrift
com.mobile.legends
com.mojang.minecraftpe
com.roblox.client
com.gameloft.android.ANMP.GloftA9HM
com.ea.gp.apexlegendsmobilefps
com.proximabeta.mf.uamo
EOF
}

# Ensure the user-editable games file exists.
ensure_games_file() {
    [ -f "$GAMES_FILE" ] || default_games > "$GAMES_FILE"
}

# Is a package installed?
pkg_installed() { pm path "$1" >/dev/null 2>&1; }
