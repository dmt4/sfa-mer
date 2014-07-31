#!/bin/bash

# Build droid-hal and other middleware
# To be executed under the Mer SDK


[ -z "$MERSDK" ] && $(dirname $0)/exec-mer.sh $0
[ -z "$MERSDK" ] && exit 0

source ~/.hadk.env

cd $ANDROID_ROOT
# THE COMMAND BELOW WILL FAIL. It's normal, carry on with the next one.
# Explanation: force installing of build-requirements by specifying the
# .inc file directly, but build-dependencies will be pulled in via
# zypper, so that the next step has all macro definitions loaded

# Uncomment the following to disable the direct root access at port 2323
# sed -i s:'$EXPLICIT_BUSYBOX':'#$EXPLICIT_BUSYBOX':g rpm/init-debug

mb2 -t $VENDOR-$DEVICE-armv7hl -s rpm/droid-hal-device.inc build
echo 'The above failure is expected!'

mb2 -t $VENDOR-$DEVICE-armv7hl -s rpm/droid-hal-$DEVICE.spec build

mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE
rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/droid-hal-*rpm
mv RPMS/*${DEVICE}* $ANDROID_ROOT/droid-local-repo/$DEVICE/
createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE

sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu ar local-$DEVICE-hal file://$ANDROID_ROOT/droid-local-repo/$DEVICE
sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu lr

# addition from me (dmt)
sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install zypper ref -f
sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install zypper -n install droid-hal-hammerhead

mb2 -t $VENDOR-$DEVICE-armv7hl -s hybris/droid-hal-configs/rpm/droid-hal-configs.spec build



# other middleware stuff
sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install ssu domain sales
sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install ssu dr sdk

sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref -f
sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper -n install droid-hal-$DEVICE-devel

mkdir -p $MER_ROOT/devel/mer-hybris
cd $MER_ROOT/devel/mer-hybris

PKG=libhybris
cd $MER_ROOT/devel/mer-hybris
if [ -d libhybris ] ; then
  cd libhybris
  git pull
else
  git clone https://github.com/mer-hybris/libhybris.git
  cd libhybris
fi
git submodule update
cd libhybris
mb2 -s ../rpm/libhybris.spec -t $VENDOR-$DEVICE-armv7hl build

mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/
rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/*.rpm
mv RPMS/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG
createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref
sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-build zypper -n rm mesa-llvmpipe

PKG=qt5-qpa-hwcomposer-plugin
cd $MER_ROOT/devel/mer-hybris
if [ -d $PKG ] ; then
  cd $PKG
  git pull
else
  git clone https://github.com/mer-hybris/$PKG.git
  cd $PKG
fi
mb2 -s rpm/$PKG.spec -t $VENDOR-$DEVICE-armv7hl build
mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/
rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/*.rpm
mv RPMS/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG

createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref

PKG=sensorfw
SPEC=sensorfw-qt5-hybris
OTHER_RANDOM_NAME=hybris-libsensorfw-qt5
cd $MER_ROOT/devel/mer-hybris
if [ -d $PKG ] ; then
  cd $PKG
  git pull
else
  git clone https://github.com/mer-hybris/$PKG.git
  cd $PKG
fi
mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build
mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/
rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/*.rpm
mv RPMS/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG
createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref

PKG=ngfd-plugin-droid-vibrator
SPEC=$PKG
cd $MER_ROOT/devel/mer-hybris
if [ -d $PKG ] ; then
  cd $PKG
  git pull
else
  git clone https://github.com/mer-hybris/$PKG.git
  cd $PKG
fi
mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build
mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/
rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/*.rpm
mv RPMS/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG
createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref

PKG=qt5-feedback-haptics-droid-vibrator
SPEC=$PKG
cd $MER_ROOT/devel/mer-hybris
if [ -d $PKG ] ; then
  cd $PKG
  git pull
else
  git clone https://github.com/mer-hybris/$PKG.git
  cd $PKG
fi
mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build
mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/
rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/*.rpm
mv RPMS/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG
createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref


PKG=pulseaudio-modules-droid
SPEC=$PKG
cd $MER_ROOT/devel/mer-hybris
if [ -d $PKG ] ; then
  cd $PKG
#  git pull
else
  git clone https://github.com/mer-hybris/$PKG.git
  cd $PKG
# this i confess is a shoddy execution
  curl https://raw.githubusercontent.com/siteshwar/pulseaudio-modules-droid/testing/src/droid/droid-util.c > src/droid/droid-util.c
  curl https://raw.githubusercontent.com/siteshwar/pulseaudio-modules-droid/testing/src/droid/droid-util.h > src/droid/droid-util.h
  curl https://raw.githubusercontent.com/siteshwar/pulseaudio-modules-droid/testing/src/droid/droid-util-44.h > src/droid/droid-util-44.h
fi
mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build
mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/
rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/*.rpm
mv RPMS/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG
createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref


