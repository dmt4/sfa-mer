TOOLDIR="$(dirname $0)/../.."
source "$TOOLDIR/utility-functions.inc"

source ~/.hadk.env

if [ ! -f device/sony/yuga/fstab.qcom ]; then
   minfo "copy default fstab to device/sony/scorpion/fstab.qcom"
   cp device/sony/fusion3-common/rootdir/fstab.qcom device/sony/scorpion/fstab.qcom
fi
