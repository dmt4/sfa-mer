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
  ls .repo/local_manifests/roomservice.xml
  rm -f .repo/local_manifests/roomservice.xml
  pushd ./device/lge/hammerhead
    git checkout cm.dependencies 
  popd  
  sed -i -n '/kernel/{N;s/.*//;x;d;};x;p;${x;p;}' ./device/lge/hammerhead/cm.dependencies  
  sed -i "/},$/d" ./device/lge/hammerhead/cm.dependencies 
  sed -i "/^$/d"  ./device/lge/hammerhead/cm.dependencies
  source build/envsetup.sh
  export USE_CCACHE=1
  breakfast $DEVICE

  ls .repo/local_manifests/roomservice.xml
  rm -f .repo/local_manifests/roomservice.xml
  echo -e "\e[01;32m done \e[00m"
  cp /home/alin/hackmanifest.xml .repo/local_manifests/manifest.xml
  sed -i "/_lge_hammerhead/d" .repo/manifests/default.xml
  echo -e "\e[01;32m Info: make -j$JOBS hybris-hal &> make-hybris-hal.stdoe \e[00m"
  make -j$JOBS hybris-hal &> make-hybris-hal.stdoe
#  rm -rf bionic
#  git clone https://github.com/mer-hybris/android_bionic/ bionic
  pushd bionic
#  git checkout hybris-11.0-44S
  git cherry-pick 40eb3772fecf40bf89d70b30f57fb0e074301d3a
  popd 
  make libc_common &> make-libc_common.stdoe
  make libc &> make-libc.stdoe
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
