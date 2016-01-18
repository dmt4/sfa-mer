#!/bin/bash
TOOLDIR="$(dirname `which $0`)"
source "$TOOLDIR/utility-functions.inc"

# Download/resync the CyanogenMod sources and compile libhybris.
# This requires humongous amount of space (18+ GiB) for nebulous, to me, reasons.
# On subsequent runs the source is updated and only dependencies are rebuild which
# does save significant amount of time.

# To be run under the Ubuntu SDK

source ~/.hadk.env

[ -z "$MERSDKUBU" ] && "$TOOLDIR"/exec-mer.sh ubu-chroot -r "$MER_ROOT/sdks/ubuntu" $0
[ -z "$MERSDKUBU" ] && exit 0

# install software in chroot
minfo "Installing additional tools for the Ubuntu chroot"
sudo apt-get install -y unzip bsdmainutils

mkdir -p ~/bin
[ -f ~/bin/repo ] || curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

# this is actually needed and not just a tiny convenience because other scripts later use it internally
export PATH=${PATH}:${HOME}/bin

if repo_is_unset "$DHD_REPO"; then
  mchapter "5.1"
  if [ ! -f "$ANDROID_ROOT/.repo/manifest.xml" ]; then
     mkdir -p "$ANDROID_ROOT"
     cd "$ANDROID_ROOT"
     repo init -u git://github.com/mer-hybris/android.git -b $BRANCH || die
  fi

  cd "$ANDROID_ROOT"

  DEVICE_CONFIG="$TOOLDIR/device/$VENDOR/manifest.xml"
  if [ -f $DEVICE_CONFIG ]; then
     minfo "Injecting manifest $DEVICE_CONFIG"
     mkdir -p .repo/local_manifests
     cp ${DEVICE_CONFIG} .repo/local_manifests/
  else
     mwarn "No manifest for device $DEVICE was found, building might not work"
     minfo "In order to allow this script to inject a manifest, deposit"
     minfo "it as $DEVICE_CONFIG"
  fi
  unset DEVICE_CONFIG

  minfo "repo sync -j $JOBS -c &> repo-sync.stdoe"
  repo sync  -j $JOBS -c &> repo-sync.stdoe || die_with_log repo-sync.stdoe
  minfo "Done with repo sync -c &> repo-sync.stdoe"

  mchapter "5.2"
  minfo "Build environment, cache and breakfast"
  if [ -f .repo/local_manifests/roomservice.xml ]; then
     minfo "Remove room service"
     rm -f .repo/local_manifests/roomservice.xml
  fi

DEVICE_SETUP_SCRIPT="$TOOLDIR/device/$VENDOR/$DEVICE-hal-build-setup.sh"
if [ -f $DEVICE_SETUP_SCRIPT ]; then
  minfo "Calling the hal build setup script $DEVICE_SETUP_SCRIPT..."
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
 # mtodo "Find better solution:"
 # minfo "Work-around for build error due to missing bouncycastle concerning dumpkey"
 # minfo "  make -j$JOBS bouncycastle-host dumpkey &> make-dumpkey.stdoe"
 # make -j$JOBS bouncycastle-host dumpkey &> make-dumpkey.stdoe || die_with_log make-dumpkey.stdoe
 # TMPDIR=`mktemp -d`
 # BC="`pwd`/$(find out/host/ -name 'bouncycastle-host.jar' | tail -n1)" 
 # DC="`pwd`/$(find out/host/ -name 'dumpkey.jar' | tail -n1)"
 # pushd ${TMPDIR} &> /dev/null 
 # unzip -oq "$BC" || die "can't unzip file $BC"
 # unzip -oq "$DC" || die "can't unzip file $DC"
 # zip -rq "$DC" . || die "can't rezip $DC"
 # popd &> /dev/null
 # rm -Rf "${TMPDIR}"
 # unset TMPDIR
 # unset BC
 # unset DC
  ######################################

  minfo "make -j$JOBS hybris-hal &> make-hybris-hal.stdoe "

  make -j$JOBS hybris-hal &> make-hybris-hal.stdoe || die_with_log make-hybris-hal.stdoe

  CREDITS="$TOOLDIR/device/$VENDOR/$DEVICE-hal-build-credits.inc"
  if [ -f ${CREDITS} ]; then
     # call additional make targets from here or whatever you need
     minfo "sourcing \"credits\" build script."
     source ${CREDITS}
  fi
  minfo "Do some magic for sensors"
  rm -rf bionic
  git clone https://github.com/mer-hybris/android_bionic/ bionic
  pushd bionic
  git checkout hybris-11.0-44S
  git cherry-pick 40eb3772fecf40bf89d70b30f57fb0e074301d3a
  popd  
  make libc_common &> make-libc_common.stdoe
  make libc &> make-libc.stdoe
#### camera bits
  minfo "Do some magic for camera"
  pushd external/droidmedia
  git reset --hard 0f8689d5203f004d234ce8b73c6068f7eb01b559
  # first bad commit bb963dba657467d53a280ac45347a51ac6fc6dd0 
  # last known working  0f8689d5203f004d234ce8b73c6068f7eb01b559
  popd
  make -j$JOBS libdroidmedia >& make-libdroidmedia.log
  make -j$JOBS minimediaservice >& make-minimediaservice.log
  make -j$JOBS minisfservice >& make-minisfservice.log
else  # DHD_REPO"
  mchapter "5.1 version b"
  if [ ! -d "$ANDROID_ROOT" ]; then
     mkdir -p "$ANDROID_ROOT"
     pushd "$ANDROID_ROOT"
      git clone git://github.com/mer-hybris/droid-hal-device rpm || die
     popd
 else
     pushd "$ANDROID_ROOT"/rpm
     git pull
     popd
  fi
fi
