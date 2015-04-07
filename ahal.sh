#!/bin/bash
TOOLDIR="$(dirname `which $0`)"
source "$TOOLDIR/utility-functions.inc"

# Build droid-hal and other middleware
# To be executed under the Mer SDK


[ -z "$MERSDK" ] && ${TOOLDIR}/exec-mer.sh $0
[ -z "$MERSDK" ] && exit 0

source ~/.hadk.env

cd $ANDROID_ROOT
# THE COMMAND BELOW WILL FAIL. It's normal, carry on with the next one.
# Explanation: force installing of build-requirements by specifying the
# .inc file directly, but build-dependencies will be pulled in via
# zypper, so that the next step has all macro definitions loaded

# Uncomment the following to disable the direct root access at port 2323
# sed -i s:'$EXPLICIT_BUSYBOX':'#$EXPLICIT_BUSYBOX':g rpm/init-debug

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

minfo "Creating manifest file..."
mkdir -p tmp
.repo/repo/repo manifest -r -o tmp/manifest.xml
mv tmp/manifest.xml repo_service_manifest.xml

minfo "Upgrading repository"
sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install zypper -n dup || die "upgrading failed"
if repo_is_unset "$DHD_REPO"; then
  mtodo "bad workaround shall be removed asap"
  minfo "sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install zypper in qt5-qttools-kmap2qmap repomd-pattern-builder cmake "
  sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install zypper -n in qt5-qttools-kmap2qmap repomd-pattern-builder cmake

  if [ ! -f rpm/droid-hal-$DEVICE.spec ]; then
     OUR_DEVICE_HAL_SPEC="$TOOLDIR/device/$VENDOR/droid-hal-$DEVICE.spec"
     echo $OUR_DEVICE_HAL_SPEC
     if [ -f "$OUR_DEVICE_HAL_SPEC" ] ; then
        minfo "There is no rpm spec in $ANDROID_ROOT/rpm,"
        minfo "however I brought one with me, will be using that :)"
        cp ${OUR_DEVICE_HAL_SPEC} rpm || die
     else
        mchapter "14.4.1"
        mwarn "There is no droid-hal-spec file for your device, creating a minimal one"
        cat <<EOF > rpm/droid-hal-$DEVICE.spec
# device is the cyanogenmod codename for the device
# eg mako is Nexus 4
%define device $DEVICE
# vendor is used in device/$VENDOR/$DEVICE/
%define vendor $VENDOR
# Manufacturer and device name to be shown in UI
%define vendor_pretty Not Yet Filled
%define device_pretty Not Yet Filled
%include rpm/droid-hal-device.inc
EOF
     fi
  fi
  if [ ! -d "rpm/patterns/$DEVICE" ] ; then
      minfo "creating patterns"
      rpm/helpers/add_new_device.sh || die
  fi

  if [ ! -d "rpm/device-$VENDOR-$DEVICE-configs/var/lib/environment" ]; then
      mchapter "14.4.2"
      mwarn "There is no device specific config, creating minimal one"
      COMPOSITOR_CFGS=rpm/device-$VENDOR-$DEVICE-configs/var/lib/environment/compositor
      mkdir -p $COMPOSITOR_CFGS
      cat <<EOF >$COMPOSITOR_CFGS/droid-hal-device.conf
# Config for $VENDOR/$DEVICE
HYBRIS_EGLPLATFORM=fbdev
QT_QPA_PLATFORM=hwcomposer
LIPSTICK_OPTIONS=-plugin evdevtouch:/dev/input/event0 \
-plugin evdevkeyboard:keymap=/usr/share/qt5/keymaps/droid.qmap
EOF
  fi
  minfo "mb2 -t $VENDOR-$DEVICE-armv7hl -s rpm/droid-hal-$DEVICE.spec build &> droid-hal-$DEVICE.log "
  mb2 -t $VENDOR-$DEVICE-armv7hl -s rpm/droid-hal-$DEVICE.spec build &> $ANDROID_ROOT/droid-hal-$DEVICE.log || die_with_log $ANDROID_ROOT/droid-hal-$DEVICE.log "Building of droid-hal-$DEVICE-* packages failed!"
  tail -n 5 droid-hal-$DEVICE.log
else
  minfo "Add remote dhd repo"
  sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu ar dhd-$DEVICE-hal $DHD_REPO
fi
minfo "Success: End of droid-hal-$DEVICE build"

mchapter "7.1.2"
minfo "Cleaning repo for $DEVICE"
rm -rf $ANDROID_ROOT/droid-local-repo/$DEVICE
mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE
rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/droid-hal-*rpm


if repo_is_set "$DHD_REPO"; then
  minfo "Getting dhd rpms from repo"
  patternrpm=$(sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install zypper se -s $DEVICE-patterns | tail -n 1 | awk '{print $2"-"$6"."$8".rpm" }')
  pushd $ANDROID_ROOT/droid-local-repo/$DEVICE ; curl -O $DHD_REPO/armv7hl/$patternrpm  ; ls;popd
else
  minfo "Moving dhd rpms"
  mv RPMS/*${DEVICE}* $ANDROID_ROOT/droid-local-repo/$DEVICE/
fi
minfo "Updating repo"
createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE


mchapter "7.1.3"
minfo "Add droid-local-repo repo"
sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu ar local-$DEVICE-hal file://$ANDROID_ROOT/droid-local-repo/$DEVICE || die
sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu lr || die

sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install zypper ref -f || die
sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install zypper -n install droid-hal-$DEVICE  || die


mchapter "7.1.4"
if repo_is_unset "$MW_REPO"; then
  minfo "mb2 -t $VENDOR-$DEVICE-armv7hl -s hybris/droid-hal-configs/rpm/droid-hal-configs.spec build &> droid-hal-configs.log "
  mb2 -t $VENDOR-$DEVICE-armv7hl -s hybris/droid-hal-configs/rpm/droid-hal-configs.spec build &> $ANDROID_ROOT/droid-hal-configs.log ||  die_with_log $ANDROID_ROOT/droid-hal-configs.log
else
  minfo "installing prebuilt hal from middleware repo..."
  sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install zypper -n install ssu-kickstarts-droid || die
fi

# other middleware stuff only if no mw repo is specified

if repo_is_unset "$MW_REPO"; then

    mchapter "8.1 "
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install ssu domain sales
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install ssu dr sdk

    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref -f
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper -n install droid-hal-$DEVICE-devel

    rm -rf $MER_ROOT/devel/mer-hybris
    mkdir -p $MER_ROOT/devel/mer-hybris
    cd $MER_ROOT/devel/mer-hybris


    ${TOOLDIR}/pkgbuild.sh libhybris || die
    
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-build zypper -n rm mesa-llvmpipe

    ${TOOLDIR}/pkgbuild.sh qt5-qpa-hwcomposer-plugin || die
    ${TOOLDIR}/pkgbuild.sh "https://github.com/mer-packages/qtsensors.git" || die
    ${TOOLDIR}/pkgbuild.sh "https://github.com/mer-packages/sensorfw.git" rpm/sensorfw-qt5-hybris.spec || die
    ${TOOLDIR}/pkgbuild.sh ngfd-plugin-droid-vibrator || die
    ${TOOLDIR}/pkgbuild.sh qt5-feedback-haptics-droid-vibrator || die
    ${TOOLDIR}/pkgbuild.sh pulseaudio-modules-droid || die
    ${TOOLDIR}/pkgbuild.sh "https://github.com/nemomobile/dsme.git" || die
    ${TOOLDIR}/pkgbuild.sh "https://github.com/nemomobile/mce-plugin-libhybris.git" || die

    ${TOOLDIR}/pkgbuild.sh qtscenegraph-adaptation || die
fi
