#!/bin/bash

# Carries the sequence of steps under the Mer SDK.
# - Set up Ubuntu for building CyanogenMod.
#   I'm highly suspicious this step could just as well be done on Mer SDk itself but lets leave it for another time..
# - Set up Scratchbox2 for crosscompiling
# - Build the droid-hal, the middleware & friends, and finally,
# - Build the image!
[ -z "$MERSDK" ] && $(dirname $0)/exec-mer.sh $0
[ -z "$MERSDK" ] && exit 0

echo -e "\e[01;33m Info: 4.3  \e[00m"
sudo zypper -n install android-tools createrepo zip

source ~/.hadk.env
echo -e "\e[01;32m Info: setup ubuntu chroot \e[00m"
UBUNTU_CHROOT=${MER_ROOT}/sdks/ubuntu
mkdir -p $UBUNTU_CHROOT

echo -e "\e[01;33m Info: 4.4.1  \e[00m"
pushd ${MER_ROOT}
TARBALL=ubuntu-trusty-android-rootfs.tar.bz2
[ -f $TARBALL  ] || curl -O http://img.merproject.org/images/mer-hybris/ubu/$TARBALL
echo -e "\e[01;32m Info: untar ubuntu \e[00m"
[ -f ${TARBALL}.untarred ] || sudo tar --numeric-owner -xjf $TARBALL -C $UBUNTU_CHROOT
touch ${TARBALL}.untarred

echo -e "\e[01;33m Info: 4.4.2  \e[00m"
grep $(hostname) ${UBUNTU_CHROOT}/etc/hosts || sudo sh -c "echo 127.0.0.2 $(hostname) >> ${UBUNTU_CHROOT}/etc/hosts"

popd

cd $(dirname $0)
# replace the shoddy ubu-chroot script
sudo cp ubu-chroot-fixed-cmd-mode `which ubu-chroot`
sudo chmod +x `which ubu-chroot`

ubu-chroot -r ${MER_ROOT}/sdks/ubuntu `pwd`/task-ubu.sh
echo -e "\e[01;32m Info: done ubuntu \e[00m"

echo -e "\e[01;33m Info: 6. sb2 setup \e[00m"
./sb-setup.sh

./ahal.sh

./build-img.sh

