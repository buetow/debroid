
log=/data/local/debroid.out
err=/data/local/debroid.err

/system/bin/date > $log

while : ; do
  /system/xbin/mountpoint /storage/sdcard1
  if [ $? -eq 0 ]; then
    cd /storage/sdcard1/Linux
    /system/bin/sh jessie.sh start_services >> $log 2> $err
    /system/bin/date >> $log
    exit 0
  fi
  /system/bin/sleep 1
done
