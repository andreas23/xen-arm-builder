#!/bin/sh -ex
# Clone github repos, and pull to refresh them if they exist

sudo apt-get -y install rsync git gcc-arm-linux-gnueabihf build-essential qemu kpartx binfmt-support qemu-user-static python bc parted dosfstools

clone_branch () {
  git clone ${1}/${2}.git
  cd $2
  if [ "$3" != "master" ]; then
    git checkout -b $3 origin/$3
  fi
  cd ..
}

if [ ! -d u-boot-sunxi ]; then
  clone_branch git://github.com/jwrdegoede u-boot-sunxi sunxi-next
else
  cd u-boot-sunxi
  git pull --ff-only origin sunxi-next
  cd ..
fi

if [ ! -d linux ]; then
  #clone_branch git://git.kernel.org/pub/scm/linux/kernel/git/torvalds linux master
  clone_branch https://github.com/talex5 linux master
else
  cd linux
  git reset HEAD --hard
  rm -rf drivers/block/blktap2 include/linux/blktap.h
  git pull --ff-only https://github.com/talex5/linux.git master
  cd ..
fi

cd linux
for i in ../patches/linux*.patch
do
  patch -p1 < $i
done
cd ..

if [ ! -d linux-firmware ]; then
  clone_branch https://git.kernel.org/pub/scm/linux/kernel/git/firmware linux-firmware master
else
  cd linux-firmware
  git pull --ff-only https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git master
  cd ..
fi

wget -O linux-firmware/brcm/brcmfmac43362-sdio.txt http://dl.cubieboard.org/public/Cubieboard/benn/firmware/ap6210/nvram_ap6210.txt


if [ ! -d xen ]; then
  #clone_branch git://xenbits.xen.org xen stable-4.4
  clone_branch https://github.com/talex5 xen stable-4.4
else
  cd xen
  #git pull origin stable-4.4
  git pull --ff-only https://github.com/talex5/xen.git stable-4.4
  cd ..
fi

