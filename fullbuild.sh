#!/bin/bash

# The main script. 
# Resets the environment, updates the Mer SDK is necessary and passes on the task to the chroot.

while (($#)); do
  case $1 in
  -h)
    echo "Correct usage: `basename $0` option value"
    echo "Valid options are:"
    echo "-merroot folder # the place where you want MER_ROOT to point"
    echo "-vendor vendorName # the vendor name "
    echo "-device deviceName # the device name "
    echo "-branch branchName # the branch name from mer hybris "
    echo "-jobs number # the number of parallel jobs to be used for parallel builds"
    echo "-extraname name # string to be added in the name of the image"
    echo "-sfrelease x.y.z.p # the release version of Sailfish OS against which the image is built"
    echo "-h displays this help"
    exit 0
  ;;
  -merroot)
    shift 
    merroot=$1
    shift
  ;;
  -vendor)
    shift 
    vendor=$1
    shift
  ;;
  -device)
    shift 
    device=$1
    shift
  ;;
  -branch)
    shift 
    branch=$1
    shift
  ;;
  -jobs)
    shift 
    jobs=$1
    shift
  ;;
  -extraname)
    shift 
    extraname=$1
    shift
  ;;
  -sfrelease)
    shift 
    sfrelease=$1
    shift
  ;;
  *)
    echo "unknown option! Use -h for the list of options!"
    exit 0
  ;;
  esac
done
test -n "$merroot" && echo "User specified \$MER_ROOT=$merroot"
test -n "$vendor" && echo "User specified \$VENDOR=$vendor"
test -n "$device" && echo "User specified \$DEVICE=$device"
test -n "$branch" && echo "User specified \$BRANCH=$branch for mer-hybris"
test -n "$jobs" && echo "User specified \$JOBS=$jobs number of jobs to be used to build"
test -n "$extraname" && echo "User specified bit for \$EXTRA_NAME is $extraname"
test -n "$sfrelease" && echo "User specified \$RELEASE=$sfrelease"

#cd $(dirname $0)
#cp hadk.env ~/.hadk.env
#cp profile-mer ~/.mersdk.profile
#cp profile-ubu ~/.mersdkubu.profile


#./setup-mer.sh
#./exec-mer.sh `pwd`/task-mer.sh

