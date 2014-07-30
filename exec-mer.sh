#!/bin/bash

# Sshorthand for running things under the Mer SDK or entering it, should no command be passed.


[ -z "$MERSDK" ] || echo 'Already in MerSDK!'
[ -z "$MERSDK" ] || exit 1

source ~/.hadk.env

${MER_ROOT}/sdks/sdk/mer-sdk-chroot $*

