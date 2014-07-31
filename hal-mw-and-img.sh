#!/bin/bash

# A convenience wrapper which only rebuilds the hal, the middleware and image.

[ -z "$MERSDK" ] && $(dirname $0)/exec-mer.sh $0
[ -z "$MERSDK" ] && exit 0

cd $(dirname $0)

./ahal.sh

./build-img.sh
