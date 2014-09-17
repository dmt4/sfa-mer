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

mkdir -p tmp
KSFL=$ANDROID_ROOT/tmp/Jolla-@RELEASE@-$DEVICE-@ARCH@.ks

echo -e "\e[01;32m Info: adaptation \e[00m"
HA_REPO="repo --name=adaptation0-$DEVICE-@RELEASE@"
sed -e "s|^$HA_REPO.*$|$HA_REPO --baseurl=file://$ANDROID_ROOT/droid-local-repo/$DEVICE|" \
  $ANDROID_ROOT/installroot/usr/share/kickstarts/$(basename $KSFL) > $KSFL

if [ x"$MW_REPO" != xx ]; then
    echo -e "\e[01;32m Info: adaptation1 \e[00m"
    HA_REPO1="repo --name=adaptation1-$DEVICE-@RELEASE@ --baseurl=${MW_REPO}"
    sed -i -e "/^$HA_REPO.*$/a$HA_REPO1" $KSFL
fi


echo -e "\e[01;32m Info: packages \e[00m"
sed -i '/@Jolla\ Configuration\ hammerhead/a sailfish-office' $KSFL
sed -i '/@Jolla\ Configuration\ hammerhead/a jolla-calculator' $KSFL
sed -i '/@Jolla\ Configuration\ hammerhead/a jolla-email' $KSFL
sed -i '/@Jolla\ Configuration\ hammerhead/a jolla-notes' $KSFL
sed -i '/@Jolla\ Configuration\ hammerhead/a jolla-clock' $KSFL
sed -i '/@Jolla\ Configuration\ hammerhead/a jolla-mediaplayer' $KSFL
sed -i '/@Jolla\ Configuration\ hammerhead/a jolla-calendar' $KSFL
sed -i '/@Jolla\ Configuration\ hammerhead/a jolla-fileman' $KSFL
sed -i '/@Jolla\ Configuration\ hammerhead/a mce-plugin-libhybris' $KSFL
sed -i '/@Jolla\ Configuration\ hammerhead/a usb-moded-pc-suite-mode-android' $KSFL
sed -i '/@Jolla\ Configuration\ hammerhead/a usb-moded-mass-storage-android-config' $KSFL
sed -i '/@Jolla\ Configuration\ hammerhead/a usb-moded-diag-mode-android' $KSFL
sed -i '/@Jolla\ Configuration\ hammerhead/a usb-moded-developer-mode-android' $KSFL
sed -i '/@Jolla\ Configuration\ hammerhead/a usb-moded-defaults-android' $KSFL
sed -i '/@Jolla\ Configuration\ hammerhead/a usb-moded-connection-sharing-android-config' $KSFL
sed -i '/@Jolla\ Configuration\ hammerhead/a usb-moded' $KSFL
sed -i '/@Jolla\ Configuration\ hammerhead/a strace' $KSFL
sed -i '/@Jolla\ Configuration\ hammerhead/a jolla-devicelock-plugin-encpartition' $KSFL
if [ x"$MW_REPO" != xx ]; then 
  sed -i '/@Jolla\ Configuration\ hammerhead/a gstreamer0.10-droidcamsrc' $KSFL
  sed -i '/@Jolla\ Configuration\ hammerhead/a gstreamer0.10-colorconv' $KSFL
  sed -i '/@Jolla\ Configuration\ hammerhead/a gstreamer0.10-droideglsink' $KSFL
  sed -i '/@Jolla\ Configuration\ hammerhead/a libgstreamer0.10-nativebuffer' $KSFL
  sed -i '/@Jolla\ Configuration\ hammerhead/a libgstreamer0.10-gralloc' $KSFL
  sed -i '/@Jolla\ Configuration\ hammerhead/a gstreamer0.10-omx' $KSFL
  sed -i '/@Jolla\ Configuration\ hammerhead/a gst-av' $KSFL
else 
  sed -i "/@Jolla\ Configuration\ hammerhead/a jolla-hw-adaptation-hammerhead" $KSFL
fi
sed -i '/@Jolla\ Configuration\ hammerhead/a -feature-xt9' $KSFL
sed -i '/@Jolla\ Configuration\ hammerhead/a -jolla-xt9-cp' $KSFL
sed -i '/@Jolla\ Configuration\ hammerhead/a -jolla-xt9' $KSFL

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


echo -e "\e[01;32m Info: patterns \e[00m"
rpm/helpers/process_patterns.sh


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
  $KSFL
echo -e "\e[01;32m Info: copy image \e[00m"
cp -av sfa-${DEVICE}-ea-${RELEASE}${EXTRA_NAME}/sailfishos-${DEVICE}-release-${RELEASE}${EXTRA_NAME}.zip $IMGDEST/
  cat $KSFL > a
