#!/bin/bash
set -e

#############
# Variables #
#############

API_KEY=
GROUP_NAME=Servers
SENSOR_NAME=sv-hive-1%20-%20Memory%20Free
UNITS=M

PATH=$PATH:/usr/bin:/usr/local/bin:/bin

###################
# Logic and stuff #
###################


value=`cat /proc/meminfo | head -4| awk 'NR == 1 { t = $2 } NR == 2 { f = $2 } NR == 3 { b = $2 } NR == 4 { c = $2 } END { print (f + b + c)/1024 }'`


curl -d "data_point[value]=$value&sensor[name]=$SENSOR_NAME&user[api_key]=$API_KEY&data_point[reporter]=Unknown&data_point[units]=$UNITS&sensor[group_name]=$GROUP_NAME" http://monocle.phantomdata.com/data_points
