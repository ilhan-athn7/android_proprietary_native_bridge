#!/bin/sh
green='\033[0;32m'
red='\033[0;31m'
nocolor='\033[0m'
wsa_bundle=$1
fname=$(basename $BASH_SOURCE)
uname=$(logname)
workdir="wsa_workdir"
magisk_dir="houdini_magisk"
mountdir="/mnt/wsa_vendor"
random=$RANDOM
clear


###Check if 7z usable
if [[ $(which 7z 2> /dev/null) == "" ]]
	then echo -e "-Please install p7zip in order to countinue." $'\n' && exit
fi


###Check and rename if workdir exist
if [ -a $workdir ];
	then mv $workdir $workdir$random
	echo -e "-Work directory exist, renaming ..." $'\n'
fi


###Check if have root privileges and filename is given
if [[ "$(whoami)" != "root" || "$wsa_bundle" == "" ]]
	then echo -e "usage: sudo sh $fname <file>" $'\n' && exit
fi


###Check if script executed in it's own directory
if [ "$(ls -1 | grep $fname)" != $fname ]
	then echo -e "-Please navigate to directory of this script." $'\n' && exit
fi


###Check if given file exist
if ! [ -a $wsa_bundle ];
	then echo -e "-File not found" $'\n' && exit
fi


###Try exyracting msix from given file
if [[ $(7z l $wsa_bundle | grep _x64_Release ) == *"_x64_Release"* ]];
	then valid=true
	else valid=false
fi &> /dev/null


if [ $valid == "true" ]
	then
		msix_file=$(7z l $wsa_bundle | grep _x64_Release | awk '{print $6}') &> /dev/null
		echo -e "-Extracting msix file from msixbundle ..." $'\n'
		7z e $wsa_bundle -y -o$workdir $msix_file &> /dev/null
		cd $workdir

		if ! [ -a $msix_file ];
			then echo -e "$red-Extraction failed! $nocolor"  && exit 1
		fi
	else
		echo -e "$red-Invalid file$nocolor" $'\n' && exit 1
fi


###Try extracting vendor.img from msix
echo -e "-Extracting vendor.img from msix ..." $'\n'
7z e $msix_file -y -oimages vendor.img &> /dev/null


if ! [ -a images/vendor.img ];
	then echo -e "$red-Extraction failed! $nocolor" && exit 1
fi


###Mount vendor.img to /dev/loop
echo -e "-Mount vendor.img to /dev/loop ..." $'\n'
mkdir -p $mountdir
cd images
mount -o loop vendor.img  $mountdir
cd ..


###Prepare magisk module structure
echo -e "-Prepare magisk module structure ..." $'\n'
mkdir -p $magisk_dir && cd $magisk_dir


p1="system/vendor"
vdirs="	system $p1 
	$p1/bin 	$p1/bin/arm	$p1/bin/arm64
	$p1/lib 	$p1/lib/arm 	$p1/lib/arm/nb
	$p1/lib64 	$p1/lib64/arm64	$p1/lib64/arm64/nb
	$p1/etc 	$p1/etc/binfmt_misc"
for dirs in $vdirs
	do mkdir -p $dirs  
done


meta="META-INF/com/google/android"
mkdir -p $meta


cat <<EOF >"$meta/update-binary"
#################
# Initialization
#################

umask 022

# echo before loading util_functions
ui_print() { echo "\$1"; }

require_new_magisk() {
  ui_print "*******************************"
  ui_print " Please install Magisk v20.4+! "
  ui_print "*******************************"
  exit 1
}

#########################
# Load util_functions.sh
#########################

OUTFD=\$2
ZIPFILE=\$3

[ -f /data/adb/magisk/util_functions.sh ] || require_new_magisk
. /data/adb/magisk/util_functions.sh
[ \$MAGISK_VER_CODE -lt 20400 ] && require_new_magisk

install_module
exit 0
EOF


cat <<EOF >"$meta/updater-script"
#MAGISK
EOF


cat <<EOF >"module.prop"
id=houdini
name=houdini
version=v1.0
versionCode=1
author=MrMiy4mo
description=Houdini for android exracted from windows subsystem for android.
EOF


cat <<EOF >"system.prop"
ro.dalvik.vm.isa.arm=x86
ro.enable.native.bridge.exec=1
ro.dalvik.vm.isa.arm64=x86_64
ro.enable.native.bridge.exec64=1
ro.dalvik.vm.native.bridge=libhoudini.so
ro.product.cpu.abilist=x86_64,x86,arm64-v8a,armeabi-v7a,armeabi
ro.product.cpu.abilist32=x86,armeabi-v7a,armeabi
ro.product.cpu.abilist64=x86_64,arm64-v8a
EOF


cat <<EOF >"service.sh"
until [[ "\$(getprop sys.boot_completed)" == "1" ]]; do sleep 1; done

	mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
	exec -- /system/bin/sh -c "echo ':arm_exe:M::\\\\x7f\\\\x45\\\\x4c\\\\x46\\\\x01\\\\x01\\\\x01\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x02\\\\x00\\\\x28::/system/bin/houdini:P' >> /proc/sys/fs/binfmt_misc/register"
	exec -- /system/bin/sh -c "echo ':arm_dyn:M::\\\\x7f\\\\x45\\\\x4c\\\\x46\\\\x01\\\\x01\\\\x01\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x03\\\\x00\\\\x28::/system/bin/houdini:P' >> /proc/sys/fs/binfmt_misc/register"
	exec -- /system/bin/sh -c "echo ':arm64_exe:M::\\\\x7f\\\\x45\\\\x4c\\\\x46\\\\x02\\\\x01\\\\x01\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x02\\\\x00\\\\xb7::/system/bin/houdini64:P' >> /proc/sys/fs/binfmt_misc/register"
	exec -- /system/bin/sh -c "echo ':arm64_dyn:M::\\\\x7f\\\\x45\\\\x4c\\\\x46\\\\x02\\\\x01\\\\x01\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x03\\\\x00\\\\xb7::/system/bin/houdini64:P' >> /proc/sys/fs/binfmt_misc/register"
EOF


cat <<EOF >"customize.sh"
# This is customize the module installation process if you need
SKIPUNZIP=0

# Check architecture and api level
api_level_arch_detect
if [ "\$ARCH" == "x64" ] && [ "\$API" -ge "31" ]; then
   ui_print "- Device platform: \$ARCH"
   ui_print "- API Level: \$API"
elif [ "\$ARCH" != "x64" ] && [ "\$API" -lt "31" ]; then
     ui_print "! Unsupport platform: \$ARCH"
     abort "! Unsupport API: \$API"
elif [ "\$ARCH" != "x64" ] || [ "\$API" -lt "31" ]; then
     ui_print "- Device platform: \$ARCH"
     ui_print "- API Level: \$API"
     if [ "\$ARCH" != "x64" ]; then
        abort "! Unsupport platform: \$ARCH"
     fi
     if [ "\$API" -lt "31" ]; then
        abort "! Unsupport API: \$API"
     fi
fi

# Replace the original libhoudini files.
REPLACE="
/system/bin/arm
/system/bin/arm64
/system/bin/houdini
/system/bin/houdini64
/system/etc/binfmt_misc
/system/lib/arm
/system/lib/libhoudini.so
/system/lib64/arm64
/system/lib64/libhoudini.so
"

mkdir -p "\$MODPATH/system/bin"
mkdir -p "\$MODPATH/system/etc"
mkdir -p "\$MODPATH/system/lib"
mkdir -p "\$MODPATH/system/lib64"
ln -sf /vendor/bin/houdini "\$MODPATH/system/bin/houdini"
ln -sf /vendor/bin/arm "\$MODPATH/system/bin/arm"
ln -sf /vendor/bin/houdini64 "\$MODPATH/system/bin/houdini64"
ln -sf /vendor/bin/arm64 "\$MODPATH/system/bin/arm64"
ln -sf /vendor/etc/binfmt_misc "\$MODPATH/system/etc/binfmt_misc"
ln -sf /vendor/lib/arm "\$MODPATH/system/lib/arm"
ln -sf /vendor/lib/libhoudini.so "\$MODPATH/system/lib/libhoudini.so"
ln -sf /vendor/lib64/arm64 "\$MODPATH/system/lib64/arm64"
ln -sf /vendor/lib64/libhoudini.so "\$MODPATH/system/lib64/libhoudini.so"

# Default permissions
set_perm_recursive \$MODPATH 0 0 0755 0644
set_perm \$MODPATH/$p1/bin/houdini 0 2000 0755
set_perm \$MODPATH/$p1/bin/houdini64 0 2000 0755
set_perm \$MODPATH/$p1/lib/libhoudini.so 0 0 0644
set_perm \$MODPATH/$p1/lib64/libhoudini.so 0 0 0644
set_perm \$MODPATH/$p1/bin/arm/linker 0 2000 0755
set_perm \$MODPATH/$p1/bin/arm64/linker64 0 2000 0755
set_perm_recursive \$MODPATH/$p1/etc/binfmt_misc 0 0 0755 0755
set_perm_recursive \$MODPATH/$p1/lib/arm 0 0 0755 0644
set_perm_recursive \$MODPATH/$p1/lib/arm/nb 0 0 0755 0644
set_perm_recursive \$MODPATH/$p1/lib64/arm64 0 0 0755 0644
set_perm_recursive \$MODPATH/$p1/lib64/arm64/nb 0 0 0755 0644
EOF


###Copy necessary files from mount point
echo -e "-Copy necessary files from mount point ..." $'\n'


cp -fa -Z $mountdir/bin/houdini		$p1/bin/
cp -fa -Z $mountdir/bin/houdini64	$p1/bin/
cp -fa -Z $mountdir/bin/arm/*		$p1/bin/arm/
cp -fa -Z $mountdir/bin/arm64/* 	$p1/bin/arm64/


cp -fa -Z $mountdir/lib/libhoudini.so	$p1/lib/
cp -fa -Z $mountdir/lib/arm/*		$p1/lib/arm/
cp -fa -Z $mountdir/lib/arm/nb/*	$p1/lib/arm/nb/


cp -fa -Z $mountdir/lib64/libhoudini.so	$p1/lib64/
cp -fa -Z $mountdir/lib64/arm64/*	$p1/lib64/arm64/
cp -fa -Z $mountdir/lib64/arm64/nb/*	$p1/lib64/arm64/nb/


cp -fa -Z $mountdir/etc/binfmt_misc/*	$p1/etc/binfmt_misc/


###Pack files in to magisk module
echo -e "-Packing files in to magisk module ..." $'\n'
7z -tzip a ../wsa_houdini.zip * &>/dev/null
if ! [ -a ../wsa_houdini.zip ];
	then echo -e "$red-Packing failed!$nocolor" && exit 1
fi


###Unmount (WIP)
echo -e "-Info: WSA$green vendor.img$nocolor will not be detached untill reboot, "  $'\n'
umount $mountdir && rmdir $mountdir &> /dev/null


###Allow access to workdir and show final product
chown $uname -R ../../$workdir
echo -e "-Job completed, your module is in $green$workdir$nocolor directory." $'\n'
echo -e "-You can now take your module and safely remove $green$workdir$nocolor directory." $'\n'
