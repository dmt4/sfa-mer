TOOLDIR="$(dirname $0)/../.."

source "$TOOLDIR/utility-functions.inc"

source ~/.hadk.env

pushd ./device/lge/hammerhead
    rm -f cm.dependencies
    git checkout cm.dependencies
popd
sed -i -n '/kernel/{N;s/.*//;x;d;};x;p;${x;p;}' ./device/lge/hammerhead/cm.dependencies
sed -i "/},$/d" ./device/lge/hammerhead/cm.dependencies
sed -i "/^$/d"  ./device/lge/hammerhead/cm.dependencies


cp /home/alin/hackmanifest.xml .repo/local_manifests/manifest.xml
sed -i "/_lge_hammerhead/d" .repo/manifests/default.xml
