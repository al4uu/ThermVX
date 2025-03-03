set_configs() {
  ui_print "- Configuration setup"
  mv "$MODPATH/thermvx.png" /data/local/tmp/ >/dev/null 2>&1
}

set_configs

set_permissions() {
  ui_print "- Setting permissions"
  set_perm_recursive "$MODPATH" 0 0 0755 0644
  for file in action.sh service.sh uninstall.sh; do
    set_perm "$MODPATH/$file" 0 0 0755
  done
  set_perm "/data/local/tmp/thermvx.png" 0 0 0644
}

set_permissions

random=$((RANDOM % 9))

if [ $random -eq 0 ]; then
    ui_print "- ThermVX Burn The Limits !"
elif [ $random -eq 1 ]; then
    ui_print "- Full Throttle No Mercy !"
elif [ $random -eq 2 ]; then
    ui_print "- Heat is Just a Number !"
elif [ $random -eq 3 ]; then
    ui_print "- No Limits, No Regrets !"
elif [ $random -eq 4 ]; then
    ui_print "- Push Harder, Burn Hotter !"
elif [ $random -eq 5 ]; then
    ui_print "- Fire Up The Performance !"
elif [ $random -eq 6 ]; then
    ui_print "- More Power More Heat !"
elif [ $random -eq 7 ]; then
    ui_print "- Unleash The Inferno !"
elif [ $random -eq 8 ]; then
    ui_print "- Melt The Competition !"
else
    ui_print "- ThermVX Welcome To Hell !"
fi
