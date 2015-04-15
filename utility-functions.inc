
function minfo {
    echo -e "\e[01;34m* $*  \e[00m"
}

function merror {
    echo -e "\e[01;31m!! $*  \e[00m"
}

function mwarn {
    echo -e "\e[01;33m# $*  \e[00m"
}

function mchapter {
    echo -e "\e[95mchapter $* \e[00m"
}

function mtodo {
    echo -e "\e[1m- TODO:\e[21m $*"
}

function die {
    if [ -z "$*" ]; then
        merror "command failed at `date`, dying..."
    else
        merror "$*"
    fi
    #merror "dropping to shell"
    #bash
    exit 1
}

function die_with_log {
    if [ -f "$1" ] ; then
        tail -n10 "$1"
        minfo "Check `pwd`/`basename $1` for full log."
    fi
    shift
    die $*
}

function repo_is_set {
    if [ -z "$1" ] || [ "$1" = "x" ]; then return 1; else return 0; fi
}

function repo_is_unset {
  if [ ! -z "$1" ] && [ "$1" != "x" ]; then return 1; else return 0; fi
}

