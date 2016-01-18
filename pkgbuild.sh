#!/bin/bash
TOOLDIR="$(dirname `which $0`)"
source "$TOOLDIR/utility-functions.inc"
source ~/.hadk.env


[ -z "$MERSDK" ] && ${TOOLDIR}/exec-mer.sh $0 $*
[ -z "$MERSDK" ] && exit 0

GIT_URL="$1"
shift

[ -z "$GIT_URL" ] && die "Please give me the git URL (or directory name, if it's already installed)."

PKG="$(basename ${GIT_URL%.git})"
minfo "Will build package $PKG"

if [  "$GIT_URL" = "$PKG" ]; then
   GIT_URL=https://github.com/mer-hybris/$PKG.git
   minfo "No git url specified, assuming $GIT_URL"
fi

cd "$MER_ROOT/devel/mer-hybris" || die
LOG="`pwd`/$PKG.log"
[ -f "$LOG" ] && rm "$LOG"

if [ ! -d $PKG ] ; then
minfo "Source code directory doesn't exist, clonig repository"
   git clone $GIT_URL  >>$LOG 2>&1|| die_with_log "$LOG" "cloning of $GIT_URL failed"
fi

cd $PKG || die 
minfo "Pulling updates..."
git pull >>$LOG 2>&1|| die_with_log "$LOG" "pulling of updates failed"
git submodule update >>$LOG 2>&1|| die_with_log "$LOG" "pulling of updates failed"

SPECS="$*"
if [ -z "$SPECS"  ]; then
   minfo "No spec files for package building specified, building all I can find."
   SPECS="rpm/*.spec"
fi

for SPEC in $SPECS ; do 
   minfo "Building $SPEC"
   mb2 -s $SPEC -t $VENDOR-$DEVICE-armv7hl build >>$LOG 2>&1|| die_with_log "$LOG" "building of package failed"
done
minfo "Building was successful, now adding packages to the repo"
mkdir -p "$ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG" >>$LOG 2>&1|| die_with_log "$LOG"
rm -f "$ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/"*.rpm >>$LOG 2>&1|| die_with_log "$LOG"
mv RPMS/*.rpm "$ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG" >>$LOG 2>&1|| die_with_log "$LOG"
createrepo "$ANDROID_ROOT/droid-local-repo/$DEVICE" >>$LOG 2>&1|| die_with_log "$LOG" "I cannot create the repo"
sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref >>$LOG 2>&1|| die_with_log "$LOG" "I cannot update package-info"

minfo "Building of $PKG finished successfully"
echo
