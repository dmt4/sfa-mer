#!/bin/bash
TOOLDIR="$(dirname $0)"
source "$TOOLDIR/utility-functions.inc"

# A convenience wrapper which only rebuilds the hal, the middleware and the image.

[ -z "$MERSDK" ] && ${TOOLDIR}/exec-mer.sh $0
[ -z "$MERSDK" ] && exit 0

cd ${TOOLDIR}

./ahal.sh

./build-img.sh
