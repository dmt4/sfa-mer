#!/bin/bash
TOOLDIR="$(dirname `which $0`)"
source "$TOOLDIR/utility-functions.inc"
# Download and untar appropriately the Mer SDK. Also try to avoid repetition.

source ~/.hadk.env

mkdir -p "$MER_ROOT/sdks/sdk"

mchapter "4.2"
cd "$MER_ROOT"
minfo "Fetching Mer"
TARBALL=mer-i486-latest-sdk-rolling-chroot-armv7hl-sb2.tar.bz2
[ -f $TARBALL  ] || curl -k -O https://img.merproject.org/images/mer-sdk/$TARBALL || die

minfo "Untaring Mer"
[ -f ${TARBALL}.untarred ] || sudo tar --numeric-owner -p -xjf "$MER_ROOT/$TARBALL" -C "$MER_ROOT/sdks/sdk" || die
touch ${TARBALL}.untarred
minfo "Done with Mer"

# These commands are a tmp workaround of glitch when working with target:
sudo zypper ar http://repo.merproject.org/obs/home:/sledge:/mer/latest_i486/ \
curlfix
sudo zypper ref curlfix
sudo zypper dup --from curlfix
