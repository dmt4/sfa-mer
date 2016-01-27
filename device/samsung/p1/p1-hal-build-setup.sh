TOOLDIR="$(dirname $0)/../.."

source "$TOOLDIR/utility-functions.inc"

source ~/.hadk.env

pushd ./device/samsung/p1
    rm -f cm.dependencies
    git checkout cm.dependencies
popd
sed -i -n '/kernel/{N;s/.*//;x;d;};x;p;${x;p;}' ./device/samsung/p1/cm.dependencies
sed -i "/},$/d" ./device/samsung/p1/cm.dependencies
sed -i "/^$/d"  ./device/samsung/p1/cm.dependencies


cp /home/alin/hackmanifest.xml .repo/local_manifests/manifest.xml
sed -i "/_samsung_p1/d" .repo/manifests/default.xml
