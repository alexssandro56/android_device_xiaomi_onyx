#!/system/bin/sh
# customize.sh - install-time, on Magisk / KernelSU / APatch.
# Tweaks-only module (NO GPU driver). Safe: no vendor libs are replaced.

ui_print " "
ui_print "  POCO F7 (onyx) - Game & Performance Tweaks (sem driver)"
ui_print " "

DEV="$(getprop ro.product.device)$(getprop ro.product.vendor.device)"
case "$DEV" in
    *onyx*) ui_print "- Device OK: onyx (POCO F7)" ;;
    *)
        ui_print "! Aviso: aparelho nao parece ser 'onyx' (POCO F7)."
        ui_print "! Detectado: ${DEV:-desconhecido}. Instalando mesmo assim"
        ui_print "! (os tweaks sao genericos e seguros)."
        ;;
esac

ui_print "- Instalando arquivos"
set_perm_recursive "$MODPATH"         0 0 0755 0644
set_perm_recursive "$MODPATH/scripts" 0 0 0755 0755
set_perm "$MODPATH/service.sh"      0 0 0755
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/action.sh"       0 0 0755

ui_print " "
ui_print "  Pronto. Reinicie para aplicar."
ui_print " "
ui_print "  * Este modulo NAO troca o driver de GPU (seguro)."
ui_print "  * Interface: KernelSU/APatch/MMRL -> 'Open WebUI'."
ui_print "    No Magisk use o botao 'Action'."
ui_print "  * Fortnite nitido: no jogo troque Anti-Aliasing de"
ui_print "    'Qualcomm GSR' para 'TAA'/'High' e 3D Resolution 100%."
