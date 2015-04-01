#!/bin/bash
TOOLDIR="$(dirname `which $0`)"
source "$TOOLDIR/utility-functions.inc"

# Download/resync the CyanogenMod sources and compile libhybris.
# This requires humongous amount of space (18+ GiB) for nebulous, to me, reasons.
# On subsequent runs the source is updated and only dependencies are rebuild which
# does save significant amount of time.

# To be run under the Ubuntu SDK

source ~/.hadk.env

[ -z "$MERSDKUBU" ] && "$TOOLDIR"/exec-mer.sh ubu-chroot -r ${MER_ROOT}/sdks/ubuntu $0
[ -z "$MERSDKUBU" ] && exit 0

# install software in chroot
#sudo apt-get install -y unzip bsdmainutils

mkdir -p ~/bin
[ -f ~/bin/repo ] || curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

# this is actually needed and not just a tiny convenience because other scripts later use it internally
export PATH=${PATH}:${HOME}/bin


if [ -z "$DHD_REPO" ]; then
  mchapter "5.1"
  if [ ! -d $ANDROID_ROOT ]; then
     mkdir -p $ANDROID_ROOT
     cd $ANDROID_ROOT
     repo init -u git://github.com/mer-hybris/android.git -b $BRANCH || die
   fi

  cd $ANDROID_ROOT

  DEVICE_CONFIG="$TOOLDIR/device/$VENDOR/$DEVICE.xml"
  if [ -f $DEVICE_CONFIG ]; then
     minfo "Injecting manifest $DEVICE_CONFIG"
     mkdir -p .repo/local_manifests
     cp ${DEVICE_CONFIG} .repo/local_manifests
  else
     mwarn "No manifest for device $DEVICE found, build might not work"
     minfo "In order to allow this script to inject a manifest, deposit"
     minfo "it as $DEVICE_CONFIG"
  fi
  unset DEVICE_CONFIG

  minfo "repo sync -j $JOBS -c &> repo-sync.stdoe"
  repo sync  -j $JOBS -c &> repo-sync.stdoe || die_with_log repo-sync.stdoe
  minfo "done repo sync -c &> repo-sync.stdoe"

  mchapter "5.2"
  minfo "build env, cache and breackfast "
  if [ -f .repo/local_manifests/roomservice.xml ]; then
     minfo "Remove room service"
     rm -f .repo/local_manifests/roomservice.xml
  fi

  DEVICE_SETUP_SCRIPT="$TOOLDIR/device/$VENDOR/$DEVICE-hal-build-setup.sh"
  if [ -f $DEVICE_SETUP_SCRIPT ]; then
     minfo "Calling hal build setup script $DEVICE_SETUP_SCRIPT"
     bash ${DEVICE_SETUP_SCRIPT}
  else
     mwarn "No hal build setup script for your $DEVICE found, build might not work"
     minfo "Place all the commands you need to run, befor building hybris-hal"
     minfo "into the file $DEVICE_SETUP_SCRIPT"
  fi
  unset DEVICE_SETUP_SCRIPT


  source build/envsetup.sh
  export USE_CCACHE=1
  breakfast $DEVICE

  ######################################
  mtodo "Find better solution:"
  minfo "Work-around for build error due to missing bouncycastle concerning dumpkey"
  make -j$JOBS bouncycastle-host dumpkey &> make-dumpkey.stdoe || die_with_log make-dumpkey.stdoe
  OUTDIR="out/target/product/$DEVICE/obj/PACKAGING/ota_keys_intermediates"
  BC="$(find out/host/ -name 'bouncycastle-host.jar' | tail -n1)"
  DC="$(find out/host/ -name 'dumpkey.jar' | tail -n1)"
  mkdir -p "${OUTDIR}"
  minfo "injecting key to ${OUTDIR}"
  java  -cp "${BC}:${DC}" com.android.dumpkey.DumpPublicKey build/target/product/security/testkey.x509.pem build/target/product/security/cm.x509.pem build/target/product/security/cm-devkey.x509.pem build/target/product/security/bacon.x509.pem  > ${OUTDIR}/key
  unset OUTDIR
  unset BC
  unset DC
  ######################################

  minfo "make -j$JOBS hybris-hal &> make-hybris-hal.stdoe "

  make -j$JOBS hybris-hal &> make-hybris-hal.stdoe || die_with_log make-hybris-hal.stdoe

  pushd bionic
  # Cherry-pick N5 sensors hack; needs to be cherry-picked to prevent build issues
  git cherry-pick 40eb3772fecf40bf89d70b30f57fb0e074301d3a
  popd 

  minfo "redoing bionic"
  make libc_common &> make-libc_common.stdoe || die_with_log make-libc_common.stdoe
  make libc &> make-libc.stdoe || die_with_log make-libc.stdoe
else  # DHD_REPO"
  mchapter "5.1 version b"
  if [ ! -d $ANDROID_ROOT ]; then
     mkdir -p $ANDROID_ROOT
     cd $ANDROID_ROOT
     git clone git://github.com/mer-hybris/droid-hal-device rpm || die
  else
     cd $ANDROID_ROOT/rpm
     git pull
  fi
fi
