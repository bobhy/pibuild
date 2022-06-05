#!/usr/bin/env -S "bash"


#loopfile=$(sudo losetup -nO NAME)

#sudo mount ${loopfile}p2 /media/bobhy/rootfs
#sudo mount ${loopfile}p1 /media/bobhy/rootfs/boot

sudo ummount /dev/sdb{1,2}
sudo mount /dev/sdb1 /media/bobhy/rootfs/boot
sudo mount /dev/sdb2 /media/bobhy/rootfs

# and run it.

sudo systemd-nspawn --machine=aimage \
    -D /media/bobhy/rootfs \
    --bind-ro=/:/pibuild/fromhost \
    --bind=$PWD/from_image/:/pibuild/tohost \
    --bind=$PWD/to_image/:/pibuild/fromsrc \
    --boot 

sudo umount /dev/sdb{1,2}
