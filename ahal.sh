#!/bin/bash
TOOLDIR="$(dirname `which $0`)"
source "$TOOLDIR/utility-functions.inc"

# Build droid-hal and other middleware
# To be executed under the Mer SDK


[ -z "$MERSDK" ] && ${TOOLDIR}/exec-mer.sh $0
[ -z "$MERSDK" ] && exit 0

source ~/.hadk.env

cd $ANDROID_ROOT

mchapter "7.1.1"

minfo "updating mer sdk"
sudo zypper ref -f ; sudo zypper -n dup

if repo_is_set "$EXTRA_REPO"; then
  minfo "Add remote extra repo"
  sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu ar extra-$DEVICE $EXTRA_REPO
fi
if repo_is_set "$MW_REPO"; then
  minfo "Add remote mw repo"
  sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu ar mw-$DEVICE-hal $MW_REPO
fi
rm -fr hybris/dhd2modular
if [[ -d hybris/dhd2modular ]] ; then 
  pushd hybris/dhd2modular
  git pull 
  popd
else
  pushd hybris
  git clone git@github.com:alinelena/dhd2modular.git
  popd
fi  
hybris/dhd2modular/dhd2modular.sh migrate 2>&1 | tee $ANDROID_ROOT/dhd.migrate.log
#./rpm/dhd/helpers/add_new_device.sh
set  -x
hybris/dhd2modular/dhd2modular.sh build 2>&1 | tee $ANDROID_ROOT/dhd.build.log
