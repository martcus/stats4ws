#!/usr/bin/env bash
#--------------------------------------------------------------------------------------------------
# stats.sh
# Copyright (c) Marco Lovazzano
# Licensed under the GNU General Public License v3.0
# http://github.com/martcus
#--------------------------------------------------------------------------------------------------

readonly STATS4WS_APPNAME="stats"
readonly STATS4WS_VERSION="1.0.0"
readonly STATS4WS_BASENAME=$(basename "$0")

# IFS stands for "internal field separator". It is used by the shell to determine how to do word splitting, i. e. how to recognize word boundaries.
readonly SAVEIFS=$IFS
IFS=$(echo -en "\n\b") # <-- change this as it depends on your app

#Param
# 1 log file

echo -e "log;operation;calls;min;mean;max;stdev;25perc;median;75perc"

# list operations
LIST_OPS="zgrep \"=Response\" \"$1\" |  cut -d\";\" -f5 | sed 's/targetOperation=//' | sort | uniq"

# loop over operations
for ops in $(eval "$LIST_OPS"); do
    _CMD="zgrep \"=Response.*$ops\" \"$1\" | cut -d\";\" -f8 | sed 's/exectime=// ; s/-->//' | sort -n"
    printf "$1;$ops;"
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
			printf "\n"
		}'
done

IFS=$SAVEIFS
exit 0
