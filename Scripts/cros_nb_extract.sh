#!/bin/bash -e
green='\033[0;32m'
red='\033[0;31m'
nocolor='\033[0m'

work_dir="$(pwd)/cros_workdir"
magisk_dir="$work_dir/cros_nb"
cros_recovery="$1"
cros_recovery_bin=$(echo "$1" | awk '{print substr($0, 1, length-4)}')
clear

run_all(){
	request_root_password
	prepare_workdir
	build_magisk_module
}



request_root_password(){
	echo -e "\n\t Root password (Needed for setting up loop device):"
	read -r -s password
	echo -e "\n\t Script will fail in case given password is wrong, or p7zip is not installed.\n"
	sleep 2
}



prepare_workdir(){
	echo -e "-Extracting android container ..."
	mkdir -p "$work_dir" && cd "$_"

	7z x ../"$cros_recovery" -y -oimages &> /dev/null
	7z e images/"$cros_recovery_bin" -y -oimages 2.ROOT-A.img &> /dev/null
	rm images/"$cros_recovery_bin"

	echo -e "-Mounting android system/vendor (Root) ..."
	echo "$password" | sudo -S sh -c ' \
		mkdir -p /mnt/cros_A /mnt/cros_system /mnt/cros_vendor && \
		mount -o loop,ro images/2.ROOT-A.img /mnt/cros_A && \
		mount -o loop,ro /mnt/cros_A/opt/google/vms/android/system.raw.img /mnt/cros_system && \
		mount -o loop,ro /mnt/cros_A/opt/google/vms/android/vendor.raw.img /mnt/cros_vendor '
}



build_magisk_module(){
	echo -e "-Prepare magisk module structure ..."
	mkdir -p "$magisk_dir" && cd "$_"

	p1="system/"
	p2="system/vendor"
	vdirs="	$p1		$p1/bin			$p2		$p2/bin
		$p1/bin/arm	$p1/bin/arm64		$p2/bin/arm	$p2/bin/arm64
		$p1/lib		$p1/lib/arm		$p2/lib		$p2/lib/arm
		$p1/lib64	$p1/lib64/arm64		$p2/lib64	$p2/lib64/arm64
		$p1/etc		$p1/etc/binfmt_misc	$p2/etc		$p2/etc/binfmt_misc"
	for dirs in $vdirs
		do mkdir -p "$dirs"
	done

	meta="META-INF/com/google/android"
	mkdir -p $meta

	cat <<EOF >"$meta/update-binary"
#################
# Initialization
#################
umask 022
ui_print() { echo "\$1"; }
OUTFD=\$2
ZIPFILE=\$3
. /data/adb/magisk/util_functions.sh
install_module
exit 0
EOF

	cat <<EOF >"$meta/updater-script"
#MAGISK
EOF

	cat <<EOF >"module.prop"
id=cros_nb
name=cros_nb
version=v1.0
versionCode=1
author=MrMiy4mo
description=Android native bridge implementation pulled from Chromebook Software.
EOF

	cat <<EOF >"system.prop"
ro.dalvik.vm.isa.arm=x86
ro.enable.native.bridge.exec=1
ro.dalvik.vm.isa.arm64=x86_64
ro.enable.native.bridge.exec64=1
ro.product.cpu.abilist=x86_64,x86,arm64-v8a,armeabi-v7a,armeabi
ro.product.cpu.abilist32=x86,armeabi-v7a,armeabi
ro.product.cpu.abilist64=x86_64,arm64-v8a
EOF

	cat <<EOF >"service.sh"
until [[ "\$(getprop sys.boot_completed)" == "1" ]]; do sleep 1; done

if ! [ -a "$MODPATH"/system/lib64/libhoudini.so ] || ! [ -a "$MODPATH"/system/vendor/lib64/libhoudini.so ] || ! [ -a "$MODPATH"/vendor/lib64/libhoudini.so ];
	setprop ro.dalvik.vm.native.bridge libndk_translation.so
else
	setprop ro.dalvik.vm.native.bridge libhoudini.so
fi
rmmod binfmt_misc
modprobe binfmt_misc
mount binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc
cat /system/etc/binfmt_misc/arm_exe >/proc/sys/fs/binfmt_misc/register
cat /system/etc/binfmt_misc/arm_dyn >/proc/sys/fs/binfmt_misc/register
cat /system/etc/binfmt_misc/arm64_exe >/proc/sys/fs/binfmt_misc/register
cat /system/etc/binfmt_misc/arm64_dyn >/proc/sys/fs/binfmt_misc/register
EOF

	cat <<EOF >"customize.sh"
#WIP
EOF

	cp /mnt/cros_A/opt/google/vms/android/ARM_TO_AMD_DBT_LICENSE.txt ./

	echo -e "-Pull blobs from chromeos recovery ..."
	echo "$password" | sudo -S sh -c "$(cat << 'EOF'
	p1="system/vendor"
	p2="system/"
	cp -r --preserve=all /mnt/cros_system/system/bin/houdini*						$p2/bin/
	cp -r --preserve=all /mnt/cros_system/system/bin/ndk_translation_program_runner_binfmt_misc*		$p2/bin/
	cp -r --preserve=all /mnt/cros_system/system/bin/arm/*							$p2/bin/arm/
	cp -r --preserve=all /mnt/cros_system/system/bin/arm64/*						$p2/bin/arm64/
	cp -r --preserve=all /mnt/cros_system/system/lib/libhoudini.so						$p2/lib/
	cp -r --preserve=all /mnt/cros_system/system/lib/libndk_translation*					$p2/lib/
	cp -r --preserve=all /mnt/cros_system/system/lib/arm/*							$p2/lib/arm/
	cp -r --preserve=all /mnt/cros_system/system/lib64/libhoudini.so					$p2/lib64/
	cp -r --preserve=all /mnt/cros_system/system/lib64/libndk_translation*					$p2/lib64/
	cp -r --preserve=all /mnt/cros_system/system/lib64/arm64/*						$p2/lib64/arm64/
        cp -r --preserve=all /mnt/cros_system/system/etc/binfmt_misc/*						$p2/etc/binfmt_misc/
	cp -r --preserve=all /mnt/cros_system/system/etc/cpuinfo*						$p2/etc/
        cp -r --preserve=all /mnt/cros_system/system/etc/ld.config*						$p2/etc/

	cp -r --preserve=all /mnt/cros_vendor/bin/houdini*							$p1/bin/
	cp -r --preserve=all /mnt/cros_vendor/bin/ndk_translation_program_runner_binfmt_misc*			$p1/bin/
	cp -r --preserve=all /mnt/cros_vendor/bin/arm/*								$p1/bin/arm/
	cp -r --preserve=all /mnt/cros_vendor/bin/arm64/*							$p1/bin/arm64/
	cp -r --preserve=all /mnt/cros_vendor/lib/libhoudini.so							$p1/lib/
	cp -r --preserve=all /mnt/cros_vendor/lib/libndk_translation*						$p1/lib/
	cp -r --preserve=all /mnt/cros_vendor/lib/arm/*								$p1/lib/arm/
	cp -r --preserve=all /mnt/cros_vendor/lib64/libhoudini.so						$p1/lib64/
	cp -r --preserve=all /mnt/cros_vendor/lib64/libndk_translation*						$p1/lib64/
	cp -r --preserve=all /mnt/cros_vendor/lib64/arm64/*							$p1/lib64/arm64/
	cp -r --preserve=all /mnt/cros_vendor/etc/binfmt_misc/*							$p1/etc/binfmt_misc/
	cp -r --preserve=all /mnt/cros_vendor/etc/cpuinfo*							$p1/etc/
        cp -r --preserve=all /mnt/cros_vendor/etc/ld.config*							$p1/etc/

EOF
)" 2>/dev/null

	echo -e "-Packing files in to magisk module ..."
	7z -tzip a ../../cros_nb.zip ./* &>/dev/null
	if ! [ -a ../../cros_nb.zip ];
		then echo -e "$red-Packing failed!$nocolor" && exit 1
		else echo -e "$green-All done, your module is saved as cros_nb.zip$nocolor"
	fi

	echo -e "-Cleaning up ..."
	cd ../..
	echo "$work_dir" >placeholder
        echo "$password" | sudo -S sh -c ' \
                umount /mnt/cros_vendor && \
                umount /mnt/cros_system && \
                umount /mnt/cros_A && \
		rmdir /mnt/cros_vendor && \
		rmdir /mnt/cros_system && \
		rmdir /mnt/cros_A && \
		rm -r $(cat placeholder) && \
		rm placeholder '
}

run_all
