#!/bin/bash

# Build & hack a kickstart file and use it to make the final image
# To be executed under the Mer SDK



[ -z "$MERSDK" ] && $(dirname $0)/exec-mer.sh $0
[ -z "$MERSDK" ] && exit 0

source ~/.hadk.env

cd $ANDROID_ROOT

mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE
createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref
sb2 -t $VENDOR-$DEVICE-armv7hl ssu lr
echo -e "\e[01;33m Info: 8.2  \e[00m"
mkdir -p tmp
KSFL=$ANDROID_ROOT/tmp/Jolla-@RELEASE@-$DEVICE-@ARCH@.ks

echo -e "\e[01;32m Info: adaptation \e[00m"
HA_REPO="repo --name=adaptation0-$DEVICE-@RELEASE@"
if [ x"$MW_REPO" != xx ]; then
   sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install cat /usr/share/kickstarts/Jolla-@RELEASE@-hammerhead-@ARCH@.ks > $KSFL
   cat $KSFL
   sed -i -e "s|^$HA_REPO.*$|$HA_REPO --baseurl=file://$ANDROID_ROOT/droid-local-repo/$DEVICE|" $KSFL
else 
  sed -e "s|^$HA_REPO.*$|$HA_REPO --baseurl=file://$ANDROID_ROOT/droid-local-repo/$DEVICE|" \
    $ANDROID_ROOT/installroot/usr/share/kickstarts/$(basename $KSFL) > $KSFL
fi 
if [ x"$DHD_REPO" != xx ]; then
  echo -e "\e[01;32m Info: dhd \e[00m"
  HA_REPO1="repo --name=adaptation1-$DEVICE-@RELEASE@ --baseurl=${DHD_REPO}"
  sed -i -e "/^$HA_REPO.*$/a$HA_REPO1" $KSFL
fi

if [ x"$MW_REPO" != xx ]; then
    echo -e "\e[01;32m Info: add mw repo \e[00m"
    HA_REPO2="repo --name=mw-$DEVICE-@RELEASE@ --baseurl=${MW_REPO}"
    sed -i -e "/^$HA_REPO.*$/a$HA_REPO2" $KSFL
fi
if [ x"$EXTRA_REPO" != xx ]; then
    echo -e "\e[01;32m Info: add mw repo \e[00m"
    HA_REPO3="repo --name=extra-$DEVICE-@RELEASE@ --baseurl=${EXTRA_REPO}"
    sed -i -e "/^$HA_REPO.*$/a$HA_REPO3" $KSFL
fi

echo -e "\e[01;32m Info: extra packages \e[00m"
PACKAGES_TO_ADD="sailfish-office jolla-calculator jolla-email jolla-notes jolla-clock jolla-mediaplayer jolla-calendar jolla-fileman mce-plugin-libhybris usb-moded-pc-suite-mode-android usb-moded-mass-storage-android-config usb-moded-diag-mode-android usb-moded-developer-mode-android usb-moded-defaults-android usb-moded-connection-sharing-android-config usb-moded strace jolla-devicelock-plugin-encsfa sailfish-version"
if [  x"$MW_REPO" != xx ]; then 
  PACKAGES_TO_ADD="$PACKAGES_TO_ADD gstreamer0.10-droidcamsrc gstreamer0.10-colorconv gstreamer0.10-droideglsink libgstreamer0.10-nativebuffer libgstreamer0.10-gralloc gstreamer0.10-omx gst-av"
fi
for pack in $PACKAGES_TO_ADD; do 
  sed -i "/@Jolla\ Configuration\ $DEVICE/a $pack" $KSFL
done

#PACKAGES_TO_REMOVE="ofono-configs-mer ssu-vendor-data-example qtscenegraph-adaptation "
PACKAGES_TO_REMOVE="ofono-configs-mer ssu-vendor-data-example"
for pack in $PACKAGES_TO_REMOVE; do 
  sed -i "/@Jolla\ Configuration\ $DEVICE/a -$pack" $KSFL
done
#  sed -i "s;@Jolla\ Configuration\ $DEVICE;@jolla-hw-adaptation-$DEVICE;g" $KSFL

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


if [ x"$MW_REPO" != xx  ]; then
  sed -i "/begin 60_ssu/a ssu ar mw $MW_REPO" $KSFL
fi
if [ x"$EXTRA_REPO" != xx ]; then
  sed -i "/begin 60_ssu/a ssu ar extra $EXTRA_REPO" $KSFL
fi
if [ x"$DHD_REPO" != xx ]; then
  sed -i "/begin 60_ssu/a ssu ar dhd $DHD_REPO" $KSFL
fi
sed -i "/begin 60_ssu/a ssu dr adaptation0" $KSFL
#sed -i "/end 70_sdk-domain/a sed -i -e 's|^adaptation=.*$|adaptation=http://repo.merproject.org/obs/nemo:/devel:/hw:/lge:/hammerhead/sailfish_1.1.0.38_armv7hl/|' /usr/share/ssu/repos.ini" $KSFL
echo -e "\e[01;33m Info: 8.3  \e[00m"
echo -e "\e[01;32m Info: create patterns \e[00m"
[ -d hybris ] || mkdir -p hybris
rpm/helpers/process_patterns.sh

echo -e "\e[01;33m Info: 8.4  \e[00m"
echo -e "\e[01;32m Info: create mic \e[00m"
# always aim for the latest:
#RELEASE=1.0.8.19
#RELEASE=latest
# WARNING: EXTRA_NAME currently does not support '.' dots in it!
EXTRA_NAME=-${EXTRA_STRING}-$(date +%Y%m%d%H%M)
cat $KSFL > ~/a
sudo mic create fs --arch armv7hl \
  --tokenmap=ARCH:armv7hl,RELEASE:$RELEASE,EXTRA_NAME:$EXTRA_NAME \
  --record-pkgs=name,url \
  --outdir=sfa-$DEVICE-$RELEASE$EXTRA_NAME \
  --pack-to=sfa-$DEVICE-$RELEASE$EXTRA_NAME.tar.bz2 \
  $KSFL 2>&1 | tee mic.log 
echo -e "\e[01;32m Info: copy image \e[00m"
cp -av sfa-${DEVICE}-${RELEASE}${EXTRA_NAME}/sailfishos-${DEVICE}-release-${RELEASE}${EXTRA_NAME}.zip $IMGDEST/

#clean repos in target
echo -e "\e[01;32m Info: clean repos in target \e[00m"

if [  x$MW_REPO != xx ] ; then 
  sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu rr mw-$DEVICE-hal
fi
if [  x$EXTRA_REPO != xx ] ; then 
  sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu rr extra-$DEVICE
fi
if [  x$DHD_REPO != xx ] ; then 
  sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu rr dhd-$DEVICE-hal
fi
sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu rr local-$DEVICE-hal
sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install zypper ref -f
sb2 -t $VENDOR-$DEVICE-armv7hl -R -m sdk-install ssu lr

 
