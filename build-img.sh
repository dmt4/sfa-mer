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
MISSING="alsa-plugins-pulseaudio ambienced apkd augeas-libs basesystem busybox-static buteo-mtp-qt5 buteo-mtp-qt5-sync-plugin buteo-syncml-qt5 buteo-sync-plugins-qt5 check commhistory-daemon connectionagent-qt5 connectionagent-qt5-declarative connman-qt5-declarative contactsd crda deltarpm droid-sans-fonts droid-sans-mono-fonts droid-serif-fonts e2fsprogs e2fsprogs-libs embedlite-components-qt5 eventsview-extensions eventsview-extensions-facebook-notifications eventsview-extensions-twitter-posts farstream file findutils fontpackages-filesystem gawk geoclue hunspell iproute iputils iw jolla-actdead-charging jolla-ca jolla-camera jolla-camera-settings jolla-common-configurations jolla-contacts jolla-contacts-settings jolla-firstsession jolla-gallery jolla-gallery-ambience jolla-gallery-facebook jolla-hacks jolla-handwriting jolla-keyboard jolla-keyboard-hwr jolla-messages jolla-messages-settings jolla-preload-ambiences jolla-preload-pictures jolla-ringtones jolla-sessions-qt5 jolla-settings-accounts jolla-settings-accounts-extensions-facebook jolla-settings-accounts-extensions-google jolla-settings-accounts-extensions-jabber jolla-settings-accounts-extensions-jolla jolla-settings-accounts-extensions-twitter jolla-settings-bluetooth jolla-settings-networking jolla-settings-sailfishos jolla-settings-system jolla-settings-transferui-qt5 jolla-signon-ui jolla-startupwizard jolla-vault jolla-vault-units kbd libaccounts-glib-tools libcom_err libcommhistory-qt5-tools libeventfeed-qt5 libmeegotouchevents-qt5 libqapk libqofono-qt5-declarative libsailfishkeyprovider-data-jolla libsocialcache-qml-plugin libss libusb1 libuser libwbxml2 lipstick-jolla-home-qt5 lsb-release maliit-framework-wayland maliit-framework-wayland-inputcontext mapplauncherd-privileges-jolla mer-release mms-engine mtp-vendor-configuration-sailfish nemo-qml-plugin-accounts-qt5 nemo-qml-plugin-contacts-qt5-tools nemo-qml-plugin-contextkit-qt5 nemo-qml-plugin-messages-internal-qt5 nemo-qml-plugin-social-qt5 nemo-qml-plugin-systemsettings nemo-qml-plugin-thumbnailer-qt5-libav net-tools obexd-calldata-provider obexd-configs-sailfish obexd-contentfilter-helper obexd-server openobex pango partnerspace-launcher passwd pm-utils prelink provisioning-service qmf-oauth2-plugin qt5-plugin-bearer-connman qt5-plugin-imageformat-gif qt5-plugin-imageformat-ico qt5-plugin-position-geoclue qt5-qtdeclarative-import-models2 qt5-qtdeclarative-systeminfo qt5-qtgraphicaleffects qt5-qtmultimedia-plugin-mediaservice-gstcamerabin qt5-qtmultimedia-plugin-resourcepolicy-resourceqt qt5-qtpositioning qt5-qtsensors-plugin-sensorfw qtmozembed-qt5 quazip quillimagefilter-qt5 rootfiles sailfish-browser sailfish-browser-settings sailfish-ca sailfish-components-store sailfish-components-timezone-qt5 sailfishsilica-qt5-demos sailfish-tutorial simkit sociald sociald-facebook-calendars sociald-facebook-contacts sociald-facebook-images sociald-facebook-notifications sociald-facebook-posts sociald-facebook-signon sociald-google-calendars sociald-google-contacts sociald-google-signon sociald-twitter-notifications sociald-twitter-posts statefs-loader-qt5 statefs-provider-bluez statefs-provider-connman statefs-provider-keyboard-generic statefs-provider-mce statefs-provider-ofono statefs-provider-profile statefs-provider-qt5 statefs-provider-upower store-client telepathy-farstream telepathy-qt5 telepathy-qt5-farstream telepathy-ring time tone-generator tracker-utils transferengine-plugins tumbler upower usbutils vim-common vim-enhanced vim-filesystem vmtouch voicecall-qt5 voicecall-ui-jolla voicecall-ui-jolla-settings wireless-regdb wireless-tools xdg-user-dirs xulrunner-qt5 zypper nss nss-softokn-freebl nss-sysinit ssu-vendor-data-jolla"
for pack in $MISSING; do 
  sed -i "/@Jolla\ Configuration\ $DEVICE/a $pack" $KSFL
done
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

sed -i "s;@Jolla Configuration $DEVICE;@jolla-hw-adaptation-$DEVICE;g" $KSFL
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
