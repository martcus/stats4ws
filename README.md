# stats4ws v1.0.0

## Prerequisites
Your log must be report a line before every response like this:
```
<!--type=Response;sessionId=null;messageId=1;targetService=Service;targetOperation=Operation;requestTime=1571379171703;responseTime=1571379172226;exectime=523-->
```

## Help
```
stats.sh v0.1.0
Statistics for web services based on axis1
Copyright (c) Marco Lovazzano
Licensed under the GNU General Public License v3.0
http://github.com/martcus

Usage: stats.sh [OPTIONS/PARAMS]
 Options:
  --help      : Print this help and exit. Option cannot be used with params
 Params
  1- File     : Log File to analyze. First param is mandatory
  2- Optional : Filter to apply to the log
```

## Example:
```
./stats.sh --help
./stats.sh ws.log
./stats.sh ws.log filter | column -t -s ';'
```
