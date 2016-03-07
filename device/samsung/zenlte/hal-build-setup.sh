TOOLDIR="$(dirname $0)/../.."
source "$TOOLDIR/utility-functions.inc"

source ~/.hadk.env

if [ ! -f device/samsung/zenlte/fstab.qcom ]; then
   minfo "copy default fstab to device/samsung/i9305/zenlte.qcom"
   cp device/samsung/zenlte/rootdir/fstab.qcom device/samsung/zenlte/fstab.qcom
fi
