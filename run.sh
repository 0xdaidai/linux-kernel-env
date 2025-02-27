#!/bin/sh

gcc exp.c -o exp -static -masm=intel -no-pie

cp ./exp ./rootfs
cd rootfs
find . -print0 \
| fakeroot cpio --null -ov --format=newc \
| gzip -9 > ../rootfs.cpio.gz
cd ..

qemu-system-x86_64 \
    -m 4G \
    -kernel bzImage \
    -initrd rootfs.cpio.gz \
    -append "root=/dev/ram rw console=ttyS0 oops=panic panic=1 kaslr quiet" \
    -cpu qemu64,+smep,+smap \
    -smp 4 \
    -netdev user,id=t0, -device e1000,netdev=t0,id=nic0 \
    -nographic --no-reboot -monitor /dev/null \
    -s
