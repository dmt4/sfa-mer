#!/bin/bash

# Download/resync the CyanogenMod sources and compile libhybris.
# This requires humongous amount of space (18+ GiB) for nebulous, to me, reasons.
# On subsequent runs the source is updated and only dependencies are rebuild which
# does save significant amount of time.

# To be run under the Ubuntu SDK

source ~/.hadk.env

[ -z "$MERSDKUBU" ] && $(dirname $0)/exec-mer.sh ubu-chroot -r ${MER_ROOT}/sdks/ubuntu $0
[ -z "$MERSDKUBU" ] && exit 0


mkdir -p ~/bin
[ -f ~/bin/repo ] || curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

# this is actually needed and not just a tiny convenience because other scripts later use it internally
export PATH=${PATH}:${HOME}/bin


if [ x"$DHD_REPO" == xx ]; then
  echo -e "\e[01;33m Info: 5.1  \e[00m"
  if [ ! -d $ANDROID_ROOT ]; then
     mkdir -p $ANDROID_ROOT
     cd $ANDROID_ROOT
     repo init -u git://github.com/mer-hybris/android.git -b $BRANCH
   fi

  cd $ANDROID_ROOT

  echo -e "\e[01;32m Info: repo sync -c &> repo-sync.stdoe \e[00m"
  repo sync -c &> repo-sync.stdoe
  echo -e "\e[01;32m Info: done repo sync -c &> repo-sync.stdoe \e[00m"

  echo -e "\e[01;33m Info: 5.2  \e[00m"
  echo -e "\e[01;32m build env, cache and breackfast \e[00m"
  source build/envsetup.sh
  export USE_CCACHE=1
  breakfast $DEVICE
  rm -f .repo/local_manifests/roomservice.xml
  echo -e "\e[01;32m done \e[00m"

  echo -e "\e[01;32m Info: make -j$JOBS hybris-hal &> make-hybris-hal.stdoe \e[00m"
  make -j$JOBS hybris-hal &> make-hybris-hal.stdoe
else 
  echo -e "\e[01;33m Info: 5.1 version b \e[00m"
  if [ ! -d $ANDROID_ROOT ]; then
     mkdir -p $ANDROID_ROOT
     cd $ANDROID_ROOT
     git clone git://github.com/mer-hybris/droid-hal-device rpm
  else
     cd $ANDROID_ROOT/rpm
     git pull
  fi
fi
