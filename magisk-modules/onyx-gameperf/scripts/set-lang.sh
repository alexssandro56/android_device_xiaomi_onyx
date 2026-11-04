#!/system/bin/sh
# ===========================================================================
# set-lang.sh <package> [locale] [quiet]
# Best-effort: set the per-app language of any app (Android 13+), as root.
# Default locale: pt-BR.
#
# HONEST NOTE: some apps (Unreal Engine games like Fortnite) read the SYSTEM
# locale directly and ignore the Android per-app language. If so, this has no
# effect and the real fix is to make the chosen language the #1 system
# language, then clear the app's cache. This never fails the module.
# ===========================================================================

DIR=${0%/*}
. "$DIR/common.sh"

PKG="$1"
LOCALE="${2:-pt-BR}"
QUIET="$3"

say() { [ "$QUIET" = "quiet" ] || echo "$*"; }

[ -n "$PKG" ] || { say "ERR: pacote nao informado"; exit 1; }

if ! pkg_installed "$PKG"; then
    log "lang: $PKG not installed, skipping"
    say "App nao instalado: $PKG"
    exit 0
fi

ok=0
if cmd locale set-app-locales "$PKG" --user 0 --locales "$LOCALE" >/dev/null 2>&1; then
    ok=1
elif cmd locale set-app-locales "$PKG" --locales "$LOCALE" >/dev/null 2>&1; then
    ok=1
fi

if [ "$ok" = 1 ]; then
    log "lang: set $PKG app-locale to $LOCALE"
    say "Idioma de $PKG definido para $LOCALE (reinicie o app)."
    say "Se nao mudar, o app pode seguir o idioma do sistema (ver README)."
else
    log "lang: cmd locale not supported for $PKG"
    say "Este Android nao aceitou idioma por app."
    say "Ajuste manual: Config > Sistema > Idiomas (coloque como 1o) e limpe o cache."
fi
exit 0
