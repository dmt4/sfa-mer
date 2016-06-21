#!/bin/bash
TOOLDIR="$(dirname `which $0`)"
source "$TOOLDIR/utility-functions.inc"

# The main script.
# Resets the environment, updates the Mer SDK is necessary and passes on the task to the chroot.

function dabspath {
    pushd "$1" > /dev/null && echo `pwd` && popd > /dev/null
}

function mdabspath {
    mkdir -p "$1"
    dabspath "$1"
    rmdir --ignore-fail-on-non-empty $1
}

# Check if git is installed
if ! which git >/dev/null; then
        echo "WARNING"
        echo "You need git to run this script"
        return
fi

while (($#)); do
  case $1 in
  -h)
    printf "Correct usage: `basename $0` [-option value]
    Valid options are:
      -mer-root folder   # the place where you want MER_ROOT to point
      -android-root folder # where to download 18GiB and compile a little of it
      -vendor vendorName # vendor name
      -device deviceName # device name
      -branch branchName # branch name from mer hybris
      -dhdrepo repo-uri  # dhd repo to be used if recompiling locally is to be avoided or x for none
      -mwrepo repo-uri   # middleware repo to be used if recompiling locally is to be avoided or x for none
      -extrarepo repo-uri # extra repo to be used if you want to pass extra packages or x for none
      -jobs number       # number of parallel jobs to be used for parallel builds
      -extraname name    # string to be added in the name of the image (beware, dots are not allowed)
      -sfrelease x.y.z.p # release version of Sailfish OS against which the image is built
      -dest folder       # where to place to the image
      -target name       # target against which to build (empty for latest)
      -h displays this help\n"
    exit 0
  ;;
  -mer-root)
    shift
    MER_ROOT=`mdabspath $1`
    shift
  ;;
  -vendor)
    shift
    VENDOR=$1
    shift
  ;;
  -device)
    shift
    DEVICE=$1
    shift
  ;;
  -branch)
    shift
    BRANCH=$1
    shift
  ;;
  -jobs)
    shift
    JOBS=$1
    shift
  ;;
  -extraname)
    shift
    EXTRA_STRING=$1
    shift
  ;;
  -sfrelease)
    shift
    RELEASE=$1
    shift
  ;;
  -dest)
    shift
    IMGDEST=`mdabspath $1`
    shift
  ;;
  -android-root)
    shift
    ANDROID_ROOT=`mdabspath $1`
    shift
  ;;
  -dhdrepo)
    shift
    DHD_REPO=$1
    shift
  ;;
  -mwrepo)
    shift
    MW_REPO=$1
    shift
  ;;
  -extrarepo)
    shift
    EXTRA_REPO=$1
    shift
  ;;
  -target)
    shift
    TARGET=$1
    shift
  ;;
  *)
    echo "unknown option! Use -h for the list of options!"
    exit 0
  ;;
  esac
done

echo 'User specified variables:'
test -n "$VENDOR"           && echo "  VENDOR=$VENDOR            "
test -n "$DEVICE"           && echo "  DEVICE=$DEVICE            "
test -n "$MER_ROOT"         && echo "  MER_ROOT=$MER_ROOT        "
test -n "$ANDROID_ROOT"     && echo "  ANDROID_ROOT=$ANDROID_ROOT"
test -n "$IMGDEST"          && echo "  IMGDEST=$IMGDEST          "
test -n "$RELEASE"          && echo "  RELEASE=$RELEASE          "
test -n "$EXTRA_STRING"     && echo "  EXTRA_STRING=$EXTRA_STRING"
test -n "$BRANCH"           && echo "  BRANCH=$BRANCH            "
test -n "$JOBS"             && echo "  JOBS=$JOBS                "
test -n "$DHD_REPO"         && echo "  DHD_REPO=$DHD_REPO          "
test -n "$MW_REPO"          && echo "  MW_REPO=$MW_REPO          "
test -n "$EXTRA_REPO"       && echo "  EXTRA_REPO=$EXTRA_REPO          "
test -n "$TARGET"           && echo "  TARGET=$TARGET          "

[ -f ~/.hadk.env ] && source ~/.hadk.env

# got to think a little more on the organisation and workflow of a multidevice setup
EXTRA_HADK_ENV="${TOOLDIR}/device/$VENDOR/$DEVICE/$DEVICE-hadk.env"
[ -f ${EXTRA_HADK_ENV} ] && minfo "Including default values from $EXTRA_HADK_ENV" || mwarn "default values file $EXTRA_HADK_ENV does not exist"
[ -f ${EXTRA_HADK_ENV} ] && source ${EXTRA_HADK_ENV}
unset EXTRA_HADK_ENV

printf "
export VENDOR=\"\${VENDOR:-$VENDOR}\"
export DEVICE=\"\${DEVICE:-$DEVICE}\"

export MER_ROOT=\"\${MER_ROOT:-$MER_ROOT}\"
export ANDROID_ROOT=\"\${ANDROID_ROOT:-$ANDROID_ROOT}\"
export IMGDEST=\"\${IMGDEST:-$IMGDEST}\"

# always aim for the latest:
export RELEASE=\"\${RELEASE:-$RELEASE}\"
export EXTRA_STRING=\"\${EXTRA_STRING:-$EXTRA_STRING}\"

export BRANCH=\"\${BRANCH:-$BRANCH}\"
export JOBS=\"\${JOBS:-$JOBS}\"

export DHD_REPO=\"\${DHD_REPO:-$DHD_REPO}\"
export MW_REPO=\"\${MW_REPO:-$MW_REPO}\"
export EXTRA_REPO=\"\${EXTRA_REPO:-$EXTRA_REPO}\"
export TARGET=\"\${TARGET:-$TARGET}\"

# printf \"vars in use:
#     VENDOR=\$VENDOR
#     DEVICE=\$DEVICE
#
#     MER_ROOT=\$MER_ROOT
#     ANDROID_ROOT=\$ANDROID_ROOT
#     IMGDEST=\$IMGDEST
#
#     RELEASE=\$RELEASE
#     EXTRA_STRING=\$EXTRA_STRING
#
#     BRANCH=\$BRANCH
#     JOBS=\$JOBS
#
#     DHD_REPO=\$DHD_REPO
#     MW_REPO=\$MW_REPO
#     EXTRA_REPO=\$EXTRA_REPO
# \"
" > ~/.hadk.env

# echo $0

mchapter "4.1"
cp ${TOOLDIR}/profile-mer ~/.mersdk.profile
cp ${TOOLDIR}/profile-ubu ~/.mersdkubu.profile

${TOOLDIR}/setup-mer.sh || die
${TOOLDIR}/exec-mer.sh ${TOOLDIR}/task-mer.sh
