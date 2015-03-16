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

echo -e "\e[01;33m Info: bad workaround shall be removed asap \e[00m"
echo -e "\e[01;33m Info: sudo rpm -U http://repo.merproject.org/obs/mer-tools:/testing/latest_i486/noarch/sdk-utils-0.65-1.19.1.noarch \e[00m"
#sudo rpm -U http://repo.merproject.org/obs/mer-tools:/testing/latest_i486/noarch/sdk-utils-0.65-1.19.1.noarch
#sudo rpm -U http://repo.merproject.org/obs/mer-tools:/testing/latest_i486/noarch/sdk-utils-0.66-1.22.1.noarch.rpm 
echo -e "\e[01;33m Info: 7.1.1 \e[00m"
if [  x$EXTRA_REPO  != xx ] ; then 
  echo -e "\e[01;32m Info: Add remote extra repo\e[00m"
  sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu ar extra-$DEVICE $EXTRA_REPO
fi
if [  x$MW_REPO != xx ] ; then 
  echo -e "\e[01;32m Info: Add remote mw repo\e[00m"
  sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu ar mw-$DEVICE-hal $MW_REPO
fi

.repo/repo/repo manifest -r -o tmp/manifest.xml
mv tmp/manifest.xml repo_service_manifest.xml
sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install zypper dup
if [ x"$DHD_REPO" == xx ]; then
  echo -e "\e[01;33m Info: bad workaround shall be removed asap \e[00m"
  echo -e "\e[01;33m Info: sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install zypper in qt5-qttools-kmap2qmap repomd-pattern-builder cmake \e[00m"
  sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install zypper in qt5-qttools-kmap2qmap repomd-pattern-builder cmake
  echo -e "\e[01;32m Info: mb2 -t $VENDOR-$DEVICE-armv7hl -s rpm/droid-hal-$DEVICE.spec build &> droid-hal-$DEVICE.log \e[00m"
  mb2 -t $VENDOR-$DEVICE-armv7hl -s rpm/droid-hal-$DEVICE.spec build &> $ANDROID_ROOT/droid-hal-$DEVICE.log
  tail -n 5 droid-hal-$DEVICE.log
else
  echo -e "\e[01;32m Info: Add remote dhd repo\e[00m"
  sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu ar dhd-$DEVICE-hal $DHD_REPO
fi
echo -e "\e[01;32m Info:: end of  droid-hal-$DEVICE build\e[00m"

echo -e "\e[01;33m Info: 7.1.2 \e[00m"
rm -rf $ANDROID_ROOT/droid-local-repo/$DEVICE
mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE
rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/droid-hal-*rpm
if [  x"$DHD_REPO" != xx  ]; then
  echo -e "\e[01;32m Info: get dhd rpms from repo\e[00m"
  patternrpm=$(sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install zypper se -s $DEVICE-patterns | tail -n 1 | awk '{print $2"-"$6"."$8".rpm" }')
  pushd $ANDROID_ROOT/droid-local-repo/$DEVICE ; curl -O $DHD_REPO/armv7hl/$patternrpm  ; ls;popd
else
  echo -e "\e[01;32m Info: move dhd rpms\e[00m"
  mv RPMS/*${DEVICE}* $ANDROID_ROOT/droid-local-repo/$DEVICE/
fi
createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
echo -e "\e[01;33m Info: 7.1.3 \e[00m"
echo -e "\e[01;32m Info: Add droid-local-repo repo\e[00m"
sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu ar local-$DEVICE-hal file://$ANDROID_ROOT/droid-local-repo/$DEVICE
sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu lr

sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install zypper ref -f
sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install zypper -n install droid-hal-$DEVICE 
echo -e "\e[01;33m Info: 7.1.4 \e[00m"
if [ x"$MW_REPO" != xx ]; then
   sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install zypper -n install ssu-kickstarts-droid
else
  echo -e "\e[01;32m Info: mb2 -t $VENDOR-$DEVICE-armv7hl -s hybris/droid-hal-configs/rpm/droid-hal-configs.spec build &> droid-hal-configs.log \e[00m"
  mb2 -t $VENDOR-$DEVICE-armv7hl -s hybris/droid-hal-configs/rpm/droid-hal-configs.spec build &> $ANDROID_ROOT/droid-hal-configs.log
  tail -n 5 $ANDROID_ROOT/droid-hal-configs.log
fi

# other middleware stuff only if no mw repo is specified

if [ x"$MW_REPO" == xx ]; then

    echo -e "\e[01;33m Info: 8.1 \e[00m"
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install ssu domain sales
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install ssu dr sdk

    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref -f
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper -n install droid-hal-$DEVICE-devel

    rm -rf $MER_ROOT/devel/mer-hybris
    mkdir -p $MER_ROOT/devel/mer-hybris
    cd $MER_ROOT/devel/mer-hybris

    PKG=libhybris
    echo -e "\e[01;32m Info: build $PKG\e[00m"
    cd $MER_ROOT/devel/mer-hybris
    if [ -d libhybris ] ; then
      echo -e "\e[01;32m Info: update the git $PKG\e[00m"
      cd $PKG
      git pull
    else
      echo -e "\e[01;32m Info: clone the git $PKG\e[00m"
      git clone https://github.com/mer-hybris/libhybris.git
      cd $PKG
    fi
    echo -e "\e[01;32m Info: update submodule $PKG\e[00m"
    git submodule update
    cd $PKG
    echo -e "\e[01;32m Info: mb2 -s ../rpm/$PKG.spec -t $VENDOR-$DEVICE-armv7hl build &> $PKG.log \e[00m"
    mb2 -s ../rpm/$PKG.spec -t $VENDOR-$DEVICE-armv7hl build &> $PKG.log
    tail -n 5 $PKG.log 
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
    echo -e "\e[01;32m Info: mb2 -s rpm/$PKG.spec -t $VENDOR-$DEVICE-armv7hl build &> $PKG.log \e[00m"
    mb2 -s rpm/$PKG.spec -t $VENDOR-$DEVICE-armv7hl build &> $PKG.log 
    tail -n 5 $PKG.log 
    mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/
    rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/*.rpm
    mv RPMS/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG
    createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref


    PKG=qtsensors
    echo -e "\e[01;32m Info: build $PKG\e[00m"
    SPEC=qtsensors
    OTHER_RANDOM_NAME=qtsensors
    mkdir -p $MER_ROOT/devel/mer-packages
    cd $MER_ROOT/devel/mer-packages
    if [ -d $PKG ] ; then
      echo -e "\e[01;32m Info: update the git $PKG\e[00m"
      cd $PKG
      git pull
    else
      echo -e "\e[01;32m Info: clone the git $PKG\e[00m"
      git clone https://github.com/mer-packages/$PKG.git
      cd $PKG
    fi
    echo -e "\e[01;32m Info: mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build &> $PKG.log \e[00m"
    mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build &> $PKG.log
    tail -n 5 $PKG.log 
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
    echo -e "\e[01;32m Info: mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build &> $PKG.log \e[00m"
    mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build &> $PKG.log
    tail -n 5 $PKG.log 
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
    echo -e "\e[01;32m Info: mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build &> $PKG.log \e[00m"
    mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build &> $PKG.log
    tail -n 5 $PKG.log 
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
    echo -e "\e[01;32m Info: mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build &> $PKG.log \e[00m"
    mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build &> $PKG.log
    tail -n 5 $PKG.log 
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
    echo -e "\e[01;32m Info: mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build &> $PKG.log \e[00m"
    mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build &> $PKG.log
    tail -n 5 $PKG.log 
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
    echo -e "\e[01;32m Info: mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build &> $PKG.log \e[00m"
    mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build &> $PKG.log
    tail -n 5 $PKG.log 
    mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/
    rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/*.rpm
    mv RPMS/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG
    createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref
   
 if [ x$TARGET == "xupdate11" ] ; then 
    PKG=qtscenegraph-adaptation
    echo -e "\e[01;32m Info: build $PKG\e[00m"
    SPEC=${PKG}-droid
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
    echo -e "\e[01;32m Info: mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build &> $PKG.log \e[00m"
    mb2 -s rpm/$SPEC.spec -t $VENDOR-$DEVICE-armv7hl build #&> $PKG.log
    tail -n 5 $PKG.log
    mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/
    rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/*.rpm
    mv RPMS/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG
    createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref
fi

fi
