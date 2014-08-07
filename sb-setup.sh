#!/bin/bash

# Set up the crosscompiling environment Scratchbox2 and test it with a tiny program.
# To be executed under the Mer SDK


[ -z "$MERSDK" ] && $(dirname $0)/exec-mer.sh $0
[ -z "$MERSDK" ] && exit 0

source ~/.hadk.env

cd $MER_ROOT

SFFE_SB2_TARGET=$MER_ROOT/targets/$VENDOR-$DEVICE-armv7hl
mkdir -p $SFFE_SB2_TARGET


TARGETS_URL=http://releases.sailfishos.org/sdk/latest/targets/targets.json
TARBALL_URL=$(curl $TARGETS_URL | grep 'armv7hl.tar.bz2' | cut -d\" -f4)
TARBALL=$(basename $TARBALL_URL)
[ -f $TARBALL ] || curl -O $TARBALL_URL
[ -f ${TARBALL}.untarred ] || sudo tar --numeric-owner -pxjf $TARBALL -C $SFFE_SB2_TARGET
[ -f ${TARBALL}.untarred ] || mv ~/.scratchbox2{,-$(date +%d-%m-%Y.%H-%M-%S)}
touch ${TARBALL}.untarred

[ $(stat -c %u $SFFE_SB2_TARGET ) == $(id -u) ] || sudo chown -R $USER $SFFE_SB2_TARGET

cd $SFFE_SB2_TARGET
grep :$(id -u): etc/passwd || grep :$(id -u): /etc/passwd >> etc/passwd
grep :$(id -g): etc/group  || grep :$(id -g): /etc/group  >> etc/group

[ x"$(sb2-config -l)" = x"$VENDOR-$DEVICE-armv7hl" ] || \
    sb2-init -d -L "--sysroot=/" -C "--sysroot=/" \
	-c /usr/bin/qemu-arm-dynamic -m sdk-build \
	-n -N -t / $VENDOR-$DEVICE-armv7hl \
	/opt/cross/bin/armv7hl-meego-linux-gnueabi-gcc
sb2 -t $VENDOR-$DEVICE-armv7hl -m sdk-install -R rpm --rebuilddb
sb2 -t $VENDOR-$DEVICE-armv7hl -m sdk-install -R zypper ar \
    -G http://repo.merproject.org/releases/mer-tools/rolling/builds/armv7hl/packages/ mer-tools-rolling
sb2 -t $VENDOR-$DEVICE-armv7hl -m sdk-install -R zypper ref --force

mkdir -p $MER_ROOT/tmp
cd $MER_ROOT/tmp

cat > main.c << EOF
#include <stdlib.h>
#include <stdio.h>
int main(void) {
  printf("URAAAA!\n");
  return EXIT_SUCCESS;
}
EOF

sb2 -t $VENDOR-$DEVICE-armv7hl gcc main.c -o test
sb2 -t $VENDOR-$DEVICE-armv7hl ./test


