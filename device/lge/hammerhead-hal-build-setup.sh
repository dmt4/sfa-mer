TOOLDIR="$(dirname `which $0`)/../.."

source "$TOOLDIR/utility-functions.inc"

source ~/.hadk.env

pushd ./device/lge/hammerhead
    git checkout cm.dependencies
popd
sed -i -n '/kernel/{N;s/.*//;x;d;};x;p;${x;p;}' ./device/lge/hammerhead/cm.dependencies
sed -i "/},$/d" ./device/lge/hammerhead/cm.dependencies
sed -i "/^$/d"  ./device/lge/hammerhead/cm.dependencies


sed -i "/_lge_hammerhead/d" .repo/manifests/default.xml
