#!/bin/bash

# The main script. 
# Resets the environment, updates the Mer SDK is necessary and passes on the task to the chroot.


cd $(dirname $0)
cp hadk.env ~/.hadk.env
cp profile-mer ~/.mersdk.profile
cp profile-ubu ~/.mersdkubu.profile


#source ~/.hadk.env


./setup-mer.sh
./exec-mer.sh `pwd`/task-mer.sh

