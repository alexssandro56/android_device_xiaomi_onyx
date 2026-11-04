#!/system/bin/sh
# customize.sh - runs at install time on Magisk / KernelSU / APatch.

ui_print "- POCO F7 (onyx) Game & Performance Tweaks v2.0.0"

DEV="$(getprop ro.product.device)$(getprop ro.product.vendor.device)"
case "$DEV" in
    *onyx*) ui_print "- Device OK: onyx (POCO F7)" ;;
    *)
        ui_print "! Aviso: aparelho nao parece ser 'onyx' (POCO F7)."
        ui_print "! Detectado: ${DEV:-desconhecido}. Instalando mesmo assim."
        ;;
esac

ui_print "- Instalando arquivos"
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive "$MODPATH/scripts" 0 0 0755 0755
set_perm "$MODPATH/service.sh"      0 0 0755
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/action.sh"       0 0 0755

ui_print "- Pronto. Reinicie para aplicar."
ui_print " "
ui_print "  INTERFACE: no KernelSU/APatch/MMRL, abra o modulo e toque"
ui_print "  em 'Open WebUI' para o painel de controle."
ui_print "  No Magisk, use o botao 'Action' do modulo."
ui_print " "
ui_print "  FORTNITE NITIDO: no jogo troque Anti-Aliasing de 'Qualcomm GSR'"
ui_print "  para 'TAA' (ou 'High') e deixe 3D Resolution em 100%."
