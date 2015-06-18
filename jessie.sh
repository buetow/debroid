#!/bin/sh

set -x

export ARG=$1
export ROOT=$(pwd)/jessie
export LOOP_DEVICE=/dev/block/loop1
export SHELL=/bin/bash

function enter_chroot {
  HOME=/root LD_PRELOAD='' chroot $ROOT $SHELL -l
}

function mount_chroot {
  mountpoint $ROOT
  if [ $? -ne 0 ]; then 
    losetup $LOOP_DEVICE $ROOT.img
    busybox mount -t ext4 $LOOP_DEVICE $ROOT
  fi
  for mountpoint in proc dev sys dev/pts; do
    mountpoint $ROOT/$mountpoint
    if [ $? -ne 0 ]; then
      busybox mount --bind /$mountpoint $ROOT/$mountpoint
    fi
  done
  #busybox mount --bind /mnt/shell/emulated $ROOT/storage/sdcard0
  mountpoint $ROOT/storage/sdcard1
  if [ $? -ne 0 ]; then
    busybox mount --bind /storage/sdcard1 $ROOT/storage/sdcard1
  fi
}

function umount_chroot {
  #busybox umount -f $ROOT/storage/sdcard0
  busybox umount -f $ROOT/storage/sdcard1
  for mountpoint in dev/pts proc dev sys; do
    busybox umount -f $ROOT/$mountpoint
  done
  busybox umount -f $ROOT
  losetup -d $LOOP_DEVICE
}

case $ARG in
  enter)
    mount_chroot
    enter_chroot
    ;;
  mount)
    mount_chroot
    ;;
  umount)
    umount_chroot
    ;;
  session)
    mount_chroot
    enter_chroot
    umount_chroot
    ;;
  *)
    echo "Usage: $0 session|mount|umount|enter"
    exit 1
    ;;
esac

