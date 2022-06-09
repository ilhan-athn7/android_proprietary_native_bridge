boot_comp(){
	if [[ $(getprop sys.boot_completed) == "1" ]]; then

		mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc

		exec -- /system/bin/sh -c "echo ':arm_exe:M::\\\\x7f\\\\x45\\\\x4c\\\\x46\\\\x01\\\\x01\\\\x01\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x02\\\\x00\\\\x28::/system/bin/houdini:P' >> /proc/sys/fs/binfmt_misc/register"
		exec -- /system/bin/sh -c "echo ':arm_dyn:M::\\\\x7f\\\\x45\\\\x4c\\\\x46\\\\x01\\\\x01\\\\x01\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x03\\\\x00\\\\x28::/system/bin/houdini:P' >> /proc/sys/fs/binfmt_misc/register"
		exec -- /system/bin/sh -c "echo ':arm64_exe:M::\\\\x7f\\\\x45\\\\x4c\\\\x46\\\\x02\\\\x01\\\\x01\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x02\\\\x00\\\\xb7::/system/bin/houdini64:P' >> /proc/sys/fs/binfmt_misc/register"
		exec -- /system/bin/sh -c "echo ':arm64_dyn:M::\\\\x7f\\\\x45\\\\x4c\\\\x46\\\\x02\\\\x01\\\\x01\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x03\\\\x00\\\\xb7::/system/bin/houdini64:P' >> /proc/sys/fs/binfmt_misc/register"

	else	
		sleep 0.5
		boot_comp
	fi
}
boot_comp
