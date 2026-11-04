#!/system/bin/sh
# ===========================================================================
# set-fortnite-lang.sh [locale] [quiet]
# Best-effort: set the per-app language of Fortnite (Android 13+).
# Default locale: pt-BR.
#
# HONEST NOTE: Fortnite is an Unreal Engine game and may read the SYSTEM
# locale directly instead of the Android per-app language. If so, this has
# no effect and the real fix is to make Portugues (Brasil) the #1 system
# language, then clear Fortnite's cache. This script never fails the module.
# ===========================================================================

DIR=${0%/*}
. "$DIR/common.sh"

LOCALE="${1:-pt-BR}"
QUIET="$2"

say() { [ "$QUIET" = "quiet" ] || echo "$*"; }

if ! pkg_installed "$FORTNITE_PKG"; then
    log "lang: Fortnite not installed, skipping"
    say "Fortnite nao esta instalado."
    exit 0
fi

ok=0
# Modern per-app locale command (needs root/elevated shell - we have root).
if cmd locale set-app-locales "$FORTNITE_PKG" --user 0 --locales "$LOCALE" >/dev/null 2>&1; then
    ok=1
elif cmd locale set-app-locales "$FORTNITE_PKG" --locales "$LOCALE" >/dev/null 2>&1; then
    ok=1
fi

if [ "$ok" = 1 ]; then
    log "lang: set Fortnite app-locale to $LOCALE"
    say "Idioma do Fortnite definido para $LOCALE (reinicie o jogo)."
    say "Se continuar em ingles, veja os passos manuais no README/WebUI."
else
    log "lang: cmd locale not supported on this ROM"
    say "Este Android nao aceitou o comando de idioma por app."
    say "Ajuste manual: Config > Sistema > Idiomas, coloque"
    say "Portugues (Brasil) como 1o idioma, depois limpe o cache do Fortnite."
fi
exit 0
