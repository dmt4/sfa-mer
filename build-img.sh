#!/bin/bash

# Build & hack a kickstart file and use it to make the final image
# To be executed under the Mer SDK



[ -z "$MERSDK" ] && $(dirname $0)/exec-mer.sh $0
[ -z "$MERSDK" ] && exit 0

source ~/.hadk.env

cd $ANDROID_ROOT
mkdir -p tmp
KSFL=$ANDROID_ROOT/tmp/Jolla-@RELEASE@-$DEVICE-@ARCH@.ks

HA_REPO="repo --name=adaptation0-$DEVICE-@RELEASE@"
sed -e "s|^$HA_REPO.*$|$HA_REPO --baseurl=file://$ANDROID_ROOT/droid-local-repo/$DEVICE|" \
  $ANDROID_ROOT/installroot/usr/share/kickstarts/$(basename $KSFL) > $KSFL


MOBS_URI="http://repo.merproject.org/obs"

#HA_REPO1="repo --name=adaptation1-$DEVICE-@RELEASE@ --baseurl=$MOBS_URI/sailfishos:/devel:/hw:/$DEVICE/sailfish_latest_@ARCH@/"
#sed -i -e "/^$HA_REPO.*$/a$HA_REPO1" $KSFL

#HA_REPO2="repo --name=adaptation1-$DEVICE-@RELEASE@ --baseurl=$MOBS_URI/home:/alin:/extra/sailfish_latest_@ARCH@/"
#sed -i -e "/^$HA_REPO.*$/a$HA_REPO2" $KSFL

#sed -i "/%post$/a echo 'KERNEL==\"hw_random\", NAME=\"hwrng\", SYMLINK+=\"%k\"' >> \/lib\/udev\/rules.d\/999-extra-rules.rulesi; udevadm trigger" $KSFL
#sed -i "/%post$/a rm -f \/lib\/systemd\/system\/sysinit.target.wants\/sys-kernel-debug.mount" $KSFL
#sed -i "/%post$/a rm -f \/usr\/lib\/qt5\/plugins\/sensors\/libqtsensors_sensorfw.so" $KSFL
#sed -i '/%post$/a sed -i \"s;WantedBy;RequiredBy;g\" \/lib\/systemd\/system\/system.mount' $KSFL
sed -i '/%post$/a echo \"RequiredBy=droid-hal-init.service\" >> \/lib\/systemd\/system\/local-fs.target' $KSFL
sed -i '/%post$/a echo \"[Install]\" >> \/lib\/systemd\/system\/local-fs.target' $KSFL


rpm/helpers/process_patterns.sh


# always aim for the latest:
#RELEASE=1.0.8.19
#RELEASE=latest
# WARNING: EXTRA_NAME currently does not support '.' dots in it!
EXTRA_NAME=-${EXTRA_STRING}-$(date +%Y%m%d%H%M)
sudo mic create fs --arch armv7hl \
  --tokenmap=ARCH:armv7hl,RELEASE:$RELEASE,EXTRA_NAME:$EXTRA_NAME \
  --record-pkgs=name,url \
  --outdir=sfa-$DEVICE-ea-$RELEASE$EXTRA_NAME \
  --pack-to=sfa-$DEVICE-ea-$RELEASE$EXTRA_NAME.tar.bz2 \
  $KSFL

cp -av sfa-${DEVICE}-ea-${RELEASE}${EXTRA_NAME}/sailfishos-${DEVICE}-release-${RELEASE}${EXTRA_NAME}.zip $IMGDEST/

