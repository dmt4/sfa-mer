#!/bin/bash

# Build & hack a kickstart file and use it to make the final image
# To be executed under the Mer SDK



[ -z "$MERSDK" ] && $(dirname $0)/exec-mer.sh $0
[ -z "$MERSDK" ] && exit 0

source ~/.hadk.env

cd $ANDROID_ROOT

echo -e "\e[01;32m Info: create repo \e[00m"
mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE
createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref
sb2 -t $VENDOR-$DEVICE-armv7hl ssu lr

echo -e "\e[01;33m Info: 8.2  \e[00m"
mkdir -p tmp
KSFL=$ANDROID_ROOT/tmp/Jolla-@RELEASE@-$DEVICE-@ARCH@.ks

echo -e "\e[01;32m Info: adaptation \e[00m"
HA_REPO="repo --name=adaptation0-$DEVICE-@RELEASE@"
sed -e "s|^$HA_REPO.*$|$HA_REPO --baseurl=file://$ANDROID_ROOT/droid-local-repo/$DEVICE|" \
  $ANDROID_ROOT/installroot/usr/share/kickstarts/$(basename $KSFL) > $KSFL

if [ -n "$EXTRA_REPO"  ]; then
    echo -e "\e[01;32m Info: add extra repo \e[00m"
    HA_REPO2="repo --name=extra-$DEVICE-@RELEASE@ --baseurl=${EXTRA_REPO}"
    sed -i -e "/^$HA_REPO.*$/a$HA_REPO2" $KSFL
fi
if [ x"$MW_REPO" != xx ]; then
    echo -e "\e[01;32m Info: adaptation1 \e[00m"
    HA_REPO1="repo --name=adaptation1-$DEVICE-@RELEASE@ --baseurl=${MW_REPO}"
    sed -i -e "/^$HA_REPO.*$/a$HA_REPO1" $KSFL
fi

echo -e "\e[01;32m Info: extra packages \e[00m"
PACKAGES_TO_ADD="sailfish-office jolla-calculator jolla-email jolla-notes jolla-clock jolla-mediaplayer jolla-calendar jolla-fileman mce-plugin-libhybris usb-moded-pc-suite-mode-android usb-moded-mass-storage-android-config usb-moded-diag-mode-android usb-moded-developer-mode-android usb-moded-defaults-android usb-moded-connection-sharing-android-config usb-moded strace jolla-devicelock-plugin-encpartition sailfish-version"
if [ -n "$EXTRA_REPO"  ]; then 
  PACKAGES_TO_ADD="$PACKAGES_TO_ADD gstreamer0.10-droidcamsrc gstreamer0.10-colorconv gstreamer0.10-droideglsink libgstreamer0.10-nativebuffer libgstreamer0.10-gralloc gstreamer0.10-omx gst-av"
fi
for pack in $PACKAGES_TO_ADD; do 
  sed -i "/@Jolla\ Configuration\ $DEVICE/a $pack" $KSFL
done

PACKAGES_TO_REMOVE="feature-xt9 jolla-xt9-cp jolla-xt9 ofono-configs-mer ssu-vendor-data-example"
for pack in $PACKAGES_TO_REMOVE; do 
  sed -i "/@Jolla\ Configuration\ $DEVICE/a -$pack" $KSFL
done

if [ -n "$DISABLE_TUTORIAL" ]; then
#Beware the order of these commands is reversed in $KSFL
  echo -e "\e[01;32m Info: disable tutorials \e[00m"
  sed -i '/%post$/a chown nemo:privileged /home/nemo/.jolla-startupwizard-usersession-done' $KSFL
  sed -i '/%post$/a chown nemo:nemo /home/nemo/.jolla-startupwizard-done'          $KSFL
  sed -i '/%post$/a touch /home/nemo/.jolla-startupwizard-done false'              $KSFL
  sed -i '/%post$/a touch /home/nemo/.jolla-startupwizard-usersession-done false'  $KSFL

  sed -i '/%post$/a dconf write "/apps/jolla-startupwizard/reached_tutorial" true' $KSFL
  sed -i '/%post$/a dconf write "/desktop/lipstick-jolla-home/first_run" false'    $KSFL
fi
echo -e "\e[01;33m Info: Add adaptation and extra repos in image  \e[00m"


if [ -n "$EXTRA_REPO"  ]; then
  sed -i "/begin 60_ssu/a ssu ar extra $EXTRA_REPO" $KSFL
fi
if [ x"$MW_REPO" != xx ]; then
  sed -i "/begin 60_ssu/a ssu ar dhd $MW_REPO" $KSFL
  sed -i "/begin 60_ssu/a ssu dr adaptation0" $KSFL
fi
cat $KSFL > a
echo -e "\e[01;33m Info: 8.3  \e[00m"
echo -e "\e[01;32m Info: create patterns \e[00m"
rpm/helpers/process_patterns.sh


echo -e "\e[01;33m Info: 8.4  \e[00m"
echo -e "\e[01;32m Info: create mic \e[00m"
# always aim for the latest:
#RELEASE=1.0.8.19
#RELEASE=latest
# WARNING: EXTRA_NAME currently does not support '.' dots in it!
EXTRA_NAME=-${EXTRA_STRING}-$(date +%Y%m%d%H%M)
sudo mic create fs --arch armv7hl \
  --tokenmap=ARCH:armv7hl,RELEASE:$RELEASE,EXTRA_NAME:$EXTRA_NAME \
  --record-pkgs=name,url \
  --outdir=sfa-$DEVICE-$RELEASE$EXTRA_NAME \
  --pack-to=sfa-$DEVICE-$RELEASE$EXTRA_NAME.tar.bz2 \
  $KSFL 2>&1 | tee mic.log 
echo -e "\e[01;32m Info: copy image \e[00m"
cp -av sfa-${DEVICE}-${RELEASE}${EXTRA_NAME}/sailfishos-${DEVICE}-release-${RELEASE}${EXTRA_NAME}.zip $IMGDEST/
