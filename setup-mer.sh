#!/bin/bash

# Download and untar appropriately the Mer SDK. Also try to avoid repetition.

source ~/.hadk.env

mkdir -p ${MER_ROOT}/sdks/sdk

cd $MER_ROOT
TARBALL=mer-i486-latest-sdk-rolling-chroot-armv7hl-sb2.tar.bz2
[ -f $TARBALL  ] || curl -k -O https://img.merproject.org/images/mer-sdk/$TARBALL
[ -f ${TARBALL}.untarred ] || sudo tar --numeric-owner -p -xjf ${MER_ROOT}/$TARBALL -C ${MER_ROOT}/sdks/sdk
touch ${TARBALL}.untarred


