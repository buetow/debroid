#!/system/bin/sh

while : ; do
  if [ -d /storage/sdcard1/Linux/jessie ]; then
    cd /storage/sdcard1/Linux && /system/bin/sh jessie.sh start_services
    /system/bin/date
    exit 0
  fi
  /system/bin/sleep 1
done
