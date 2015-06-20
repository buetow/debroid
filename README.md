Debroid
=======

Install a full blown Debian GNU/Linux Chroot on a LG G3 D855 CyanogenMod 12. Needs root and needs developer mode activated.

![](https://github.com/buetow/debroid/blob/master/Deboroid.png)

On Linux (tested on Fedora 22) prepare a Debian GNU/Linux Jessie base image.

```code
sudo yum install debootstrap
# 5g
dd if=/dev/zero of=jessie.img bs=$[ 1024 * 1024 ] \
  count=$[ 1024 * 5 ]

# Show used loop devices
losetup -f
# Use the next free one (replace the loop number)
losetup /dev/loop0 jessie.img

mkdir jessie
sudo mkfs.ext4 /dev/loop0
sudo mount /dev/loop0 jessie
sudo debootstrap --foreign --variant=minibase \
  --arch armel jessie jessie/ \
  http://http.debian.net/debian
sudo umount jessie
```

Initial (manual) setup on external SD card on the Phone via Android Debugger:

```
adb root
adb shell
mkdir -p /storage/sdcard1/Linux/jessie
exit
adb push jessie.img /storage/sdcard1/Linux
adb shell
cd /storage/sdcard1/Linux
# Show used loop devices
losetup -f
# Use the next free one (replace the loop number)
losetup /dev/block/loop1 $(pwd)/jessie.img
mount -t ext4 /dev/block/loop1 $(pwd)/jessie
# Bind-Mound proc, dev, sys`
busybox mount --bind /proc $(pwd)/jessie/proc
busybox mount --bind /dev $(pwd)/jessie/dev
busybox mount --bind /dev/pts $(pwd)/jessie/dev/pts
busybox mount --bind /sys $(pwd)/jessie/sys
# Bind-Mound the rest of Android
mkdir -l $(pwd)/jessie/storage/sdcard{0,1}
busybox mount --bind /mnt/shell/emulated \
  $(pwd)/jessie/storage/sdcard0
busybox mount --bind /storage/sdcard1 \
  $(pwd)/jessie/storage/sdcard1
# Check mounts
mount | grep jessie
```

Second debootstrap stage, but inside the chroot on android!
```
LD_PRELOAD='' chroot $(pwd)/jessie /bin/bash -l
export PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin
/debootstrap/debootstrap --second-stage
exit
```

Last setup steps

```
sh jessie.sh enter
cat <<END >~/.bashrc
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
export EDITOR=vim
hostname $(cat /etc/hostname)
# Fixing an error messages while loading the profile
sed -i s#id#/usr/bin/id# /etc/profile

# Setting the hostname
echo phobos > /etc/hostname
echo 127.0.0.1 phobos > /etc/hosts
hostname phobos

# Apt-sources
cat <<END > sources.list
deb http://ftp.uk.debian.org/debian/ jessie main contrib non-free
deb-src http://ftp.uk.debian.org/debian/ jessie main contrib non-free
END
apt-get update
exit
```

Debroid services startup
```
sh jessie.sh enter
cat <<END > /etc/rc.debroid
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
service uptimed status &>/dev/null || service uptimed start
exit 0
END
chmod 0755 /etc/rc.debroid
exit
```

Enter chroot script (as root):

```
cp jessie.sh /storage/sdcard1/Linux/jessie.sh
cd /storage/sdcard1/Linux
sh jessie.sh enter
cat /etc/debian_version
exit
```

Include to Android startup 

```
# This script is called from /etc/init.d/*userinit, but
# does not exist yet, so create it now
cat <<END >/data/local/userinit.sh
#!/system/bin/sh

cd /storage/sdcard1/Linux
sh jessie.sh start_services
END
```

Enjoy!

