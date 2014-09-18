#!/bin/bash

# Download and untar appropriately the Mer SDK. Also try to avoid repetition.

source ~/.hadk.env

mkdir -p ${MER_ROOT}/sdks/sdk

echo -e "\e[01;33m Info: 4.2  \e[00m"
cd $MER_ROOT
echo -e "\e[01;32m Info: setup mer \e[00m"
TARBALL=mer-i486-latest-sdk-rolling-chroot-armv7hl-sb2.tar.bz2
[ -f $TARBALL  ] || curl -k -O https://img.merproject.org/images/mer-sdk/$TARBALL
echo -e "\e[01;32m Info: untar mer \e[00m"
[ -f ${TARBALL}.untarred ] || sudo tar --numeric-owner -p -xjf ${MER_ROOT}/$TARBALL -C ${MER_ROOT}/sdks/sdk
touch ${TARBALL}.untarred
echo -e "\e[01;32m Info: done mer \e[00m"


