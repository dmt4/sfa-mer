Sailfish/Mer image build scripts
--------------------------------

The set of scripts aims to help preparing Sailfish/Mer images for the Nexus 5 pocket computer in a clean, easy and reprodicible way. They have been largely written by following [the guide](http://releases.sailfishos.org/sfa-ea/2014-07-21_SailfishOSHardwareAdaptationDevelopmentKit.pdf), [the wiki](https://wiki.merproject.org/wiki/Building_Sailfish_OS_for_Nexus_5) and advice from alin, sledges, vgrad and others from #sailfishos-porters at irc.freenode.org.

## Instructions

  - Read the scripts starting from fullbuild.sh and try to understand what goes on and why!

  - Backup ~/.hadk.env, ~/.mersdk.profile and ~/.mersdkubu.profile if you with to keep them. They will be overwriten!

  - Set MER_ROOT in hadk.env to an empty (nonexistant is acceptable too) location which gets bind-mounted in the subsequent SDK chroots. This condition usually restricts choice to a directory under ${HOME}. The scripts should also reside in such accessible directory. Making it work with any other location is a piece of homework for the curious reader.

  - Make sure the .sh files are executable and start the 'fullbuild.sh' script. After a shortwhile it will ask for the root password to enter the Mer chroot.

  - If all goes suffessfull, after an hour or so, a freshly baked image shall appear in the current working directory.


## Notes

  - If you have ~/.scratchbox2 it will be autobacked up to ~/.scratchbox2-$(date +%d-%m-%Y.%H-%M-%S) .

  - After successfull build the different scripts can be used manually intependently to update certain parts of the build. However they are not ducumented yet.

  - Repeated execution of the script is intended to only update the sources and rebuild the differences, the middleware and the image.


## **WARNING**

  **CLOSE THE UNHINDERED ROOT ACCESS AT PORT 2323 BEFORE CONNECTING TO THE NET**



Copyright (C) 2014 Dimitar Pashov <d.pashov@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


## USAGE EXAMPLE
./fullbuild.sh -mer-root nexus5 -device hammerhead -vendor lge -extrastring dmt -sfrelease 1.0.8.19 -jobs 8 -branch hybris-11.0
