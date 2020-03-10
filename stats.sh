#!/usr/bin/env bash
#--------------------------------------------------------------------------------------------------
# avg.sh
# Copyright (c) Marco Lovazzano
# Licensed under the GNU General Public License v3.0
# http://github.com/martcus
#--------------------------------------------------------------------------------------------------

readonly STATS4WS_APPNAME="avg"
readonly STATS4WS_VERSION="1.0.0"
readonly STATS4WS_BASENAME=$(basename "$0")

# IFS stands for "internal field separator". It is used by the shell to determine how to do word splitting, i. e. how to recognize word boundaries.
readonly SAVEIFS=$IFS
IFS=$(echo -en "\n\b") # <-- change this as it depends on your app


#Param
# 1 file di log

echo -e "log;operation;calls;min;max;median;mean"

# identifico l'elenco dei servizi disponibili
LIST_OPS="zgrep \"=Response\" \"$1\" |  cut -d\";\" -f5 | sed 's/targetOperation=//' | sort | uniq"

for ops in $(eval "$LIST_OPS"); do
    _CMD="zgrep \"=Response.*$ops\" \"$1\" | cut -d\";\" -f8 | sed 's/exectime=// ; s/-->//' | sort -n"

    printf "$1;$ops;"
	 echo $(eval "$_CMD") | tr ' ' '\n' | awk '
		{ a[i++]=$0; s+=$0 } 
		END { 
			printf "%.0f;%.0f;%.0f;%.0f;%.0f\n", i, a[0], a[i-1], (a[int(i/2)]+a[int((i-1)/2)])/2, s/i 
		}'
done

IFS=$SAVEIFS
exit 0
