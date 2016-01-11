TOOLDIR="$(dirname $0)/../.."

source "$TOOLDIR/utility-functions.inc"

source ~/.hadk.env

pushd ./device/sony/scorpion
    rm -f cm.dependencies
    git checkout cm.dependencies
popd
sed -i -n '/kernel/{N;s/.*//;x;d;};x;p;${x;p;}' ./device/sony/scorpion/cm.dependencies
sed -i "/},$/d" ./device/sony/scorpion/cm.dependencies
sed -i "/^$/d"  ./device/sony/scorpion/cm.dependencies


cp /home/alin/hackmanifest.xml .repo/local_manifests/manifest.xml
sed -i "/_sony_scorpion/d" .repo/manifests/default.xml
