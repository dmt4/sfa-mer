#!/bin/bash

# Carries the sequence of steps under the Mer SDK.
# - Set up Ubuntu for building CyanogenMod.
#   I'm highly suspicious this step could just as well be done on Mer SDk itself but lets leave it for another time..
# - Set up Scratchbox2 for crosscompiling
# - Build the droid-hal, the middleware & friends, and finally,
# - Build the image!

[ -z "$MERSDK" ] && $(dirname $0)/exec-mer.sh $0

sudo zypper -n install android-tools createrepo zip

source ~/.hadk.env
UBUNTU_CHROOT=${MER_ROOT}/sdks/ubuntu
mkdir -p $UBUNTU_CHROOT

pushd ${MER_ROOT}
TARBALL=ubuntu-trusty-android-rootfs.tar.bz2
[ -f $TARBALL  ] || curl -O http://img.merproject.org/images/mer-hybris/ubu/$TARBALL
[ -f ${TARBALL}.untarred ] || sudo tar --numeric-owner -xjf $TARBALL -C $UBUNTU_CHROOT
touch ${TARBALL}.untarred

grep $(hostname) ${UBUNTU_CHROOT}/etc/hosts || sudo sh -c "echo 127.0.0.2 $(hostname) >> ${UBUNTU_CHROOT}/etc/hosts"

popd

cd $(dirname $0)
# replace the shoddy ubu-chroot script
sudo cp ubu-chroot-fixed-cmd-mode `which ubu-chroot`
sudo chmod +x `which ubu-chroot`

ubu-chroot -r ${MER_ROOT}/sdks/ubuntu `pwd`/task-ubu.sh


./sb-setup.sh

./ahal.sh

./build-img.sh



