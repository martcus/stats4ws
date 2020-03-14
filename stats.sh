#!/usr/bin/env bash
#--------------------------------------------------------------------------------------------------
# stats.sh
# Copyright (c) Marco Lovazzano
# Licensed under the GNU General Public License v3.0
# http://github.com/martcus
#--------------------------------------------------------------------------------------------------

readonly STATS4WS_APPNAME="stats"
readonly STATS4WS_VERSION="0.1.0"
readonly STATS4WS_BASENAME=$(basename "$0")

# IFS stands for "internal field separator". It is used by the shell to determine how to do word splitting, i. e. how to recognize word boundaries.
readonly SAVEIFS=$IFS
IFS=$(echo -en "\n\b") # <-- change this as it depends on your app

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
# set -o xtrace

# Set magic variables for current file & dir
readonly __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly __file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
readonly __base="$(basename "${__file}" .sh)"
readonly __root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

# Variable
stats4ws_debug="N"
stats4ws_logfile="$1"
stats4ws_filter=${2:-""}

# print debug message
# parameters:
# 1- message to echo
# usage: _debug "Hello, World!"
function _debug() {
    if [ "$stats4ws_debug" = "Y" ]; then
        echo "DEBUG> $1"
    fi
}

# print help and exit with code 0
function _help() {
    echo -e ""
    echo -e "$(basename "$0") v$STATS4WS_VERSION"
    echo -e "Statistics for web services based on axis1"
    echo -e "Copyright (c) Marco Lovazzano"
    echo -e "Licensed under the GNU General Public License v3.0"
    echo -e "http://github.com/martcus"
    echo -e ""
    echo -e "Usage: $STATS4WS_BASENAME [OPTIONS/PARAMS]"
    echo -e " Options:"
    echo -e "  --help      : Print this help and exit. Option cannot be used with params "
    echo -e " Params"
    echo -e "  1- File     : Log File to analyze. First param is mandatory"
    echo -e "  2- Optional : Filter to apply to the log"
    echo -e ""
    echo -e "Usage example:"
    echo -e "./stats.sh --help"
    echo -e "./stats.sh ws.log"
	echo -e "./stats.sh ws.log filter | column -t -s ';'"
}

# print header
function _header {
    echo "log;operation;calls;min;mean;max;stdev;25perc;median;75perc;85perc;95perc"
}

if [ "$stats4ws_logfile" = "--help" ]; then
    _help
    exit 0
fi

_header

# list operations
_LIST="zgrep \"=Response.*$stats4ws_filter\" \"$stats4ws_logfile\" |  cut -d\";\" -f5 | sed 's/targetOperation=//' | sort | uniq"
_debug "$_LIST"

# loop over operations
for ops in $(eval "$_LIST"); do
    _CMD="zgrep \"=Response.*$ops\" \"$stats4ws_logfile\" | cut -d\";\" -f8 | sed 's/exectime=// ; s/-->//' | sort -n"
    _debug "$_CMD"

    printf "$stats4ws_logfile;$ops;"
    echo $(eval "$_CMD") | tr ' ' '\n' | awk '
        {
            a[i++]=$0; s+=$0; sumsq+=$0*$0
        }
        END {
            printf "%.0f" , i
            printf ";%.0f", a[0]
            printf ";%.0f", s/NR
            printf ";%.0f", a[i-1]
            printf ";%.0f", sqrt(sumsq/NR - (s/NR)**2)
            printf ";%.0f", a[int(NR*0.25 - 0.5)]
            printf ";%.0f", (a[int(i/2)]+a[int((i-1)/2)])/2
            printf ";%.0f", a[int(NR*0.75 - 0.5)]
            printf ";%.0f", a[int(NR*0.85 - 0.5)]
            printf ";%.0f", a[int(NR*0.95 - 0.5)]
            printf "\n"
        }'
done

# Restore IFS
IFS=$SAVEIFS
exit 0
