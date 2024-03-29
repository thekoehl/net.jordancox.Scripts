#!/bin/bash
set -e

#############
# Variables #
#############

API_KEY=
GROUP_NAME=Servers
SENSOR_NAME=sv-hive-1%20-%20Disk%20Free%20External
UNITS=G

PATH=$PATH:/usr/bin:/usr/local/bin:/bin

###################
# Logic and stuff #
###################


value=`/bin/df -k | /usr/bin/awk '{ if (NR==9) print $4/1024/1024 }'`


curl -d "data_point[value]=$value&sensor[name]=$SENSOR_NAME&user[api_key]=$API_KEY&data_point[reporter]=Unknown&data_point[units]=$UNITS&sensor[group_name]=$GROUP_NAME" http://monocle.phantomdata.com/data_points
