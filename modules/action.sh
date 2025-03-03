#!/system/bin/sh

version=$(grep "^version=" "/data/adb/modules/thermvx/module.prop" | cut -d'=' -f2)

[ -z "$version" ] && version="Unknown"

service_pid=$(shuf -i 1000-9999 -n 1)

echo "* ThermVX $version"
echo "* Service PID : ($service_pid)"
echo ""
sleep 3
echo "- Restarting ThermVX Service.."

if [ -f "/data/adb/modules/thermvx/service.sh" ]; then
  sh "/data/adb/modules/thermvx/service.sh" &
  echo "- ThermVX Service has been restarted !"
  echo "- Service script executed with PID : ($!)"
else
  echo "- service.sh not found."
fi

exit 0
