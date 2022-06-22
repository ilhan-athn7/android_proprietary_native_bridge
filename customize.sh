# This is customize the module installation process if you need
SKIPUNZIP=0

# Check architecture and api level
api_level_arch_detect
if [ "$ARCH" == "x64" ] && [ "$API" -ge "31" ]; then
   ui_print "- Device platform: $ARCH"
   ui_print "- API Level: $API"
elif [ "$ARCH" != "x64" ] && [ "$API" -lt "31" ]; then
     ui_print "! Unsupport platform: $ARCH"
     abort "! Unsupport API: $API"
elif [ "$ARCH" != "x64" ] || [ "$API" -lt "31" ]; then
     ui_print "- Device platform: $ARCH"
     ui_print "- API Level: $API"
     if [ "$ARCH" != "x64" ]; then
        abort "! Unsupport platform: $ARCH"
     fi
     if [ "$API" -lt "31" ]; then
        abort "! Unsupport API: $API"
     fi
fi

# Replace the original libhoudini or libndk_translation files
REPLACE="
/system/bin/arm
/system/bin/arm64
/system/bin/houdini
/system/bin/houdini64
/system/bin/ndk_translation_program_runner_binfmt_misc
/system/bin/ndk_translation_program_runner_binfmt_misc_arm64
/system/etc/binfmt_misc
/system/etc/ld.config.arm.txt
/system/etc/ld.config.arm64.txt
/system/lib/arm
/system/lib/libndk_translation.so
/system/lib/libndk_translation_*.so
/system/lib64/arm64
/system/lib64/libndk_translation.so
/system/lib64/libndk_translation_*.so
"

# Default permissions
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/system/bin/houdini 0 0 0755
set_perm $MODPATH/system/bin/houdini64 0 0 0755
set_perm $MODPATH/system/lib/libhoudini.so 0 0 0755
set_perm $MODPATH/system/lib64/libhoudini.so 0 0 0755
set_perm $MODPATH/system/vendor/bin/houdini 0 0 0755
set_perm $MODPATH/system/vendor/bin/houdini64 0 0 0755
set_perm $MODPATH/system/vendor/lib/libhoudini.so 0 0 0755
set_perm $MODPATH/system/vendor/lib64/libhoudini.so 0 0 0755
set_perm $MODPATH/system/vendor/bin/arm/linker 0 0 0755
set_perm $MODPATH/system/vendor/bin/arm64/linker64 0 0 0755
set_perm_recursive $MODPATH/system/vendor/etc/binfmt_misc 0 0 0755 0755
set_perm_recursive $MODPATH/system/vendor/lib/arm 0 0 0755 0755
set_perm_recursive $MODPATH/system/vendor/lib/arm/nb 0 0 0755 0755
set_perm_recursive $MODPATH/system/vendor/lib64/arm64 0 0 0755 0755
set_perm_recursive $MODPATH/system/vendor/lib64/arm64/nb 0 0 0755 0755
