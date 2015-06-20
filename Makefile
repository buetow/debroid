shell:
	adb wait-for-device && adb shell
reboot:
	adb reboot && adb wait-for-device && adb shell
push:
	adb push storage/sdcard1/Linux/jessie.sh /storage/sdcard1/Linux
	adb push data/local/debroid.sh /data/local
