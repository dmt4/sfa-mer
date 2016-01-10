TOOLDIR="$(dirname $0)/../.."
source "$TOOLDIR/utility-functions.inc"

source ~/.hadk.env

if [ ! -f device/samsung/i9305/fstab.qcom ]; then
   minfo "copy default fstab to device/samsung/i9305/fstab.qcom"
   cp device/samsung/smdk4412-qcom-common/rootdir/fstab.qcom device/samsung/i9305/fstab.qcom
fi
