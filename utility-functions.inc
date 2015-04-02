
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
    [ -f "$1" ] && tail -n10 "$1"
    shift
    die $*
}
