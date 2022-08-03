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

mkdir -p "$MODPATH/system/bin"
mkdir -p "$MODPATH/system/etc"
mkdir -p "$MODPATH/system/lib"
mkdir -p "$MODPATH/system/lib64"
ln -sf /vendor/bin/houdini "$MODPATH/system/bin/houdini"
ln -sf /vendor/bin/arm "$MODPATH/system/bin/arm"
ln -sf /vendor/bin/houdini64 "$MODPATH/system/bin/houdini64"
ln -sf /vendor/bin/arm64 "$MODPATH/system/bin/arm64"
ln -sf /vendor/etc/binfmt_misc "$MODPATH/system/etc/binfmt_misc"
ln -sf /vendor/lib/arm "$MODPATH/system/lib/arm"
ln -sf /vendor/lib/libhoudini.so "$MODPATH/system/lib/libhoudini.so"
ln -sf /vendor/lib64/arm64 "$MODPATH/system/lib64/arm64"
ln -sf /vendor/lib64/libhoudini.so "$MODPATH/system/lib64/libhoudini.so"

# Default permissions
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/system/vendor/bin/houdini 0 2000 0755
set_perm $MODPATH/system/vendor/bin/houdini64 0 2000 0755
set_perm $MODPATH/system/vendor/lib/libhoudini.so 0 0 0644
set_perm $MODPATH/system/vendor/lib64/libhoudini.so 0 0 0644
set_perm $MODPATH/system/vendor/bin/arm/linker 0 2000 0755
set_perm $MODPATH/system/vendor/bin/arm64/linker64 0 2000 0755
set_perm_recursive $MODPATH/system/vendor/etc/binfmt_misc 0 0 0755 0755
set_perm_recursive $MODPATH/system/vendor/lib/arm 0 0 0755 0644
set_perm_recursive $MODPATH/system/vendor/lib/arm/nb 0 0 0755 0644
set_perm_recursive $MODPATH/system/vendor/lib64/arm64 0 0 0755 0644
set_perm_recursive $MODPATH/system/vendor/lib64/arm64/nb 0 0 0755 0644