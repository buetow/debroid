#!/system/bin/sh

while : ; do
  /system/xbin/mountpoint /storage/sdcard1
  if [ $? -eq 0 ]; then
    cd /storage/sdcard1/Linux
    /system/bin/sh jessie.sh start_services 
    /system/bin/date
    exit 0
  fi
  /system/bin/sleep 1
done
