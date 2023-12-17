am start -n com.miHoYo.GenshinImpact/com.miHoYo.GetMobileInfo.MainActivity

sleep 15

GI_pid="$(echo `pidof com.miHoYo.GenshinImpact`)"

for limit_core in $GI_pid;
do taskset -ap 1 $limit_core;
done
