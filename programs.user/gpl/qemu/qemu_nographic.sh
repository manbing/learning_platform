#! /bin/bash
echo [$0][$1]


case $1 in
start)
	sudo qemu-system-arm -M vexpress-a9 -cpu cortex-a9 -m 1024M -kernel ./arm-image/kernel/zImage -dtb arm-image/kernel/vexpress-v2p-ca9.dtb -initrd arm-image/rootfs.img -append "root=/dev/ram rdinit=/sbin/init ip=dhcp console=ttyAMA0" -nographic -net user,hostfwd=tcp::2222-:22 -net nic,model=lan9118
;;

x86)
	sudo qemu-system-x86_64 -smp 2 -m 2G -kernel ./x86_64-linux/kernel/bzImage -initrd ./x86_64-linux/rootfs.cpio.gz -append "root=/dev/ram rdinit=/sbin/init console=ttyS0" -nographic -net nic -net tap,ifname=tap0,script=no
;;

kgdb)
	sudo qemu-system-arm -M vexpress-a9 -cpu cortex-a9 -m 1024M -net nic -net tap -kernel ./arm-image/kernel/zImage -dtb arm-image/kernel/vexpress-v2p-ca9.dtb -initrd arm-image/rootfs.img -append "root=/dev/ram rdinit=/sbin/init kgdboc=ttyAMA0,115200 kgdbwait" -serial tcp::1234,server
;;

gdb)
	sudo qemu-system-arm -M vexpress-a9 -cpu cortex-a9 -m 1024M -net user,hostfwd=tcp::2222-:22 -net nic,model=lan9118 -kernel ./arm-image/kernel/zImage -dtb arm-image/kernel/vexpress-v2p-ca9.dtb -initrd arm-image/rootfs.img -serial stdio -append "root=/dev/ram rdinit=/sbin/init" -S -gdb tcp::1234
;;

host_bridge)
	sudo ip address del 192.168.110.132/24 dev ens33
	sudo ip link add name br0 type bridge
	sudo ip link set br0 up
	sudo ip address add 192.168.110.132/24 dev br0
	sudo ip link set ens33 up
	sudo ip link set ens33 master br0
	sudo ip route add  default via 192.168.110.2 dev br0
;;

qemu_bridge)
	sudo ip link set tap0 up
	sudo ip link set tap0 master br0
;;

*)
	echo "[start|host_bridge|qemu_bridge]"
;;
esac
