shell:
	adb wait-for-device && adb shell
reboot:
	adb reboot && adb wait-for-device && adb shell

