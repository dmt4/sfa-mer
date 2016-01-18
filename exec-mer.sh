#!/bin/bash
TOOLDIR="$(dirname `which $0`)"
source "$TOOLDIR/utility-functions.inc"

# Shorthand for running things under the Mer SDK or entering it, should no command be passed.

[ -z "$MERSDK" ] || echo 'Already in the Mer SDK!'
[ -z "$MERSDK" ] || exit 1

source ~/.hadk.env

minfo "Chrooting to Mer"
"$MER_ROOT/sdks/sdk/mer-sdk-chroot" $*
minfo "Left the Mer chroot"
