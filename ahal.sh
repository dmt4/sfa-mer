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

#echo -e "\e[01;35m The above failure is expected! \e[00m"
#mb2 -t $VENDOR-$DEVICE-armv7hl -s rpm/droid-hal-device.inc build
#echo -e "\e[01;35m The above failure is expected! \e[00m"
if [ x"$MW_REPO" == xx ]; then
  echo -e "\e[01;32m Info: mb2 -t $VENDOR-$DEVICE-armv7hl -s rpm/droid-hal-$DEVICE.spec build \e[00m"
  mb2 -t $VENDOR-$DEVICE-armv7hl -s rpm/droid-hal-$DEVICE.spec build
fi

echo -e "\e[01;32m Info:: end of  droid-hal-$DEVICE build\e[00m"
mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE
rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/droid-hal-*rpm
if [ x"$MW_REPO" == xx ]; then
  echo -e "\e[01;32m Info: move dhd rpms\e[00m"
  mv RPMS/*${DEVICE}* $ANDROID_ROOT/droid-local-repo/$DEVICE/
else
  echo -e "\e[01;32m Info: get dhd rpms from repo\e[00m"
  osc -A https://api.merproject.org co nemo:devel:hw:$VENDOR:$DEVICE droid-hal-$DEVICE
  mv nemo:devel:hw:$VENDOR:$DEVICE/droid-hal-$DEVICE/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/
  rm -rf "nemo:devel:hw:$VENDOR:$DEVICE"
fi

createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE

sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu ar local-$DEVICE-hal file://$ANDROID_ROOT/droid-local-repo/$DEVICE
if [  x"$MW_REPO" != xx ]; then
  sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu ar remote-$DEVICE-hal $MW_REPO
fi
sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu lr

sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install zypper ref -f
sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install zypper -n install droid-hal-$DEVICE

mb2 -t $VENDOR-$DEVICE-armv7hl -s hybris/droid-hal-configs/rpm/droid-hal-configs.spec build
# other middleware stuff only if no mw repo is specified
if [ x"$MW_REPO" == xx ]; then
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install ssu domain sales
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install ssu dr sdk

    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref -f
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper -n install droid-hal-$DEVICE-devel

    mkdir -p $MER_ROOT/devel/mer-hybris
    cd $MER_ROOT/devel/mer-hybris

    PKG=libhybris
    echo -e "\e[01;32m Info: build $PKG\e[00m"
    cd $MER_ROOT/devel/mer-hybris
    if [ -d libhybris ] ; then
      echo -e "\e[01;32m Info: update the git $PKG\e[00m"
      cd libhybris
      git pull
    else
      echo -e "\e[01;32m Info: clone the git $PKG\e[00m"
      git clone https://github.com/mer-hybris/libhybris.git
      cd libhybris
    fi
    echo -e "\e[01;32m Info: update submodule $PKG\e[00m"
    git submodule update
    version=$(grep Version rpm/libhybris.spec | awk '{print $2}')
    mkdir -p libhybris-$version
    cp -r libhybris libhybris-$version/
    tar -cjf rpm/libhybris-${version}.tar.bz2  libhybris-$version
    mb2 -s rpm/libhybris.spec -t $VENDOR-$DEVICE-armv7hl build
    mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/
    rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/*.rpm
    mv RPMS/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG
    createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-build zypper -n rm mesa-llvmpipe


    PKG=qt5-qpa-hwcomposer-plugin
    echo -e "\e[01;32m Info: build $PKG\e[00m"
    cd $MER_ROOT/devel/mer-hybris
    if [ -d $PKG ] ; then
      echo -e "\e[01;32m Info: update the git $PKG\e[00m"
      cd $PKG
      git pull
    else
      echo -e "\e[01;32m Info: clone the git $PKG\e[00m"
      git clone https://github.com/mer-hybris/$PKG.git
      cd $PKG
    fi
    version=$(grep Version rpm/$PKG.spec | awk '{print $2}')
    mkdir -p ${PKG}-$version
    cp -r hwcomposer ${PKG}-$version/
    tar -cjf rpm/${PKG}-${version}.tar.bz2  ${PKG}-$version
    mb2 -s rpm/$PKG.spec -t $VENDOR-$DEVICE-armv7hl build
    mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/
    rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/*.rpm
    mv RPMS/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG
    createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref


    PKG=sensorfw
    echo -e "\e[01;32m Info: build $PKG\e[00m"
    SPEC=sensorfw-qt5-hybris
    OTHER_RANDOM_NAME=hybris-libsensorfw-qt5
    cd $MER_ROOT/devel/mer-hybris
    if [ -d $PKG ] ; then
      echo -e "\e[01;32m Info: update the git $PKG\e[00m"
      cd $PKG
      git pull
    else
      echo -e "\e[01;32m Info: clone the git $PKG\e[00m"
      git clone https://github.com/mer-hybris/$PKG.git
      cd $PKG
    fi
    version=$(grep Version rpm/$SPEC.spec | awk '{print $2}')
    mkdir -p ${OTHER_RANDOM_NAME}-$version
    cp -r * ${OTHER_RANDOM_NAME}-$version/
    tar -cjf rpm/${OTHER_RANDOM_NAME}-${version}.tar.bz2  ${OTHER_RANDOM_NAME}-$version
    mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build
    mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/
    rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/*.rpm
    mv RPMS/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG
    createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref


    PKG=ngfd-plugin-droid-vibrator
    echo -e "\e[01;32m Info: build $PKG\e[00m"
    SPEC=$PKG
    cd $MER_ROOT/devel/mer-hybris
    if [ -d $PKG ] ; then
      echo -e "\e[01;32m Info: update the git $PKG\e[00m"
      cd $PKG
      git pull
    else
      echo -e "\e[01;32m Info: clone the git $PKG\e[00m"
      git clone https://github.com/mer-hybris/$PKG.git
      cd $PKG
    fi
    version=$(grep Version rpm/$SPEC.spec | awk '{print $2}')
    mkdir -p ${PKG}-$version
    cp -r * ${PKG}-$version/
    tar -cjf rpm/${PKG}-${version}.tar.gz  ${PKG}-$version
    mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build
    mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/
    rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/*.rpm
    mv RPMS/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG
    createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref
    

    PKG=qt5-feedback-haptics-droid-vibrator
    echo -e "\e[01;32m Info: build $PKG\e[00m"
    SPEC=$PKG
    cd $MER_ROOT/devel/mer-hybris
    if [ -d $PKG ] ; then
      echo -e "\e[01;32m Info: update the git $PKG\e[00m"
      cd $PKG
      git pull
    else
      echo -e "\e[01;32m Info: clone the git $PKG\e[00m"
      git clone https://github.com/mer-hybris/$PKG.git
      cd $PKG
    fi
    version=$(grep Version rpm/$SPEC.spec | awk '{print $2}')
    mkdir -p ${PKG}-$version
    cp -r * ${PKG}-$version/
    tar -cjf rpm/${PKG}-${version}.tar.bz2  ${PKG}-$version
    mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build
    mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/
    rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/*.rpm
    mv RPMS/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG
    createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref


    PKG=pulseaudio-modules-droid
    echo -e "\e[01;32m Info: build $PKG\e[00m"
    SPEC=$PKG
    cd $MER_ROOT/devel/mer-hybris
    if [ -d $PKG ] ; then
      echo -e "\e[01;32m Info: update the git $PKG\e[00m"
      cd $PKG
      git pull
    else
      echo -e "\e[01;32m Info: clone the git $PKG\e[00m"
      git clone https://github.com/mer-hybris/$PKG.git
      cd $PKG
    fi
    pulseversion=$(grep "define pulseversion" rpm/$SPEC.spec | awk '{print $3}')
    ve=$(grep Version rpm/$SPEC.spec | awk '{print $2}')
    version=$(echo $ve | sed "s;%{pulseversion};$pulseversion;g")
    mkdir -p ${PKG}-$version
    cp -r * ${PKG}-$version/
    tar -cjf rpm/${PKG}-${version}.tar.bz2  ${PKG}-$version
    mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build
    mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/
    rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/*.rpm
    mv RPMS/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG
    createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref

    PKG=dsme
    echo -e "\e[01;32m Info: build $PKG\e[00m"
    SPEC=$PKG
    cd $MER_ROOT/devel/mer-hybris
    if [ -d $PKG ] ; then
      echo -e "\e[01;32m Info: update the git $PKG\e[00m"
      cd $PKG
      git pull
    else
      echo -e "\e[01;32m Info: clone the git $PKG\e[00m"
      git clone https://github.com/nemomobile/$PKG.git
      cd $PKG
    fi
    version=$(grep Version rpm/$SPEC.spec | awk '{print $2}')
    mkdir -p ${PKG}-$version
    cp -r * ${PKG}-$version/
    tar -cjf rpm/${PKG}-${version}.tar.gz  ${PKG}-$version
    mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build
    mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/
    rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/*.rpm
    mv RPMS/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG
    createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref
 
    PKG=mce-plugin-libhybris
    echo -e "\e[01;32m Info: build $PKG\e[00m"
    SPEC=$PKG
    cd $MER_ROOT/devel/mer-hybris
    if [ -d $PKG ] ; then
      echo -e "\e[01;32m Info: update the git $PKG\e[00m"
      cd $PKG
      git pull
    else
      echo -e "\e[01;32m Info: clone the git $PKG\e[00m"
      git clone https://github.com/nemomobile/$PKG.git
      cd $PKG
    fi
    version=$(grep Version rpm/$SPEC.spec | awk '{print $2}')
    mkdir -p ${PKG}-$version
    cp -r * ${PKG}-$version/
    tar -cjf rpm/${PKG}-${version}.tar.bz2  ${PKG}-$version
    mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build
    mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/
    rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/*.rpm
    mv RPMS/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG
    createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref
fi
