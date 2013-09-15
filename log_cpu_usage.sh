#!/bin/bash
set -e

#############
# Variables #
#############

API_KEY=
GROUP_NAME=Servers
SENSOR_NAME=sv-hive-1%20-%20CPU%20Usage
UNITS=Percent

PATH=$PATH:/usr/bin:/usr/local/bin:/bin

###################
# Logic and stuff #
###################

value=`uptime | awk '{print $12*100}'`
curl -d "data_point[value]=$value&sensor[name]=$SENSOR_NAME&user[api_key]=$API_KEY&data_point[reporter]=Unknown&data_point[units]=$UNITS&sensor[group_name]=$GROUP_NAME" http://monocle.phantomdata.com/data_points
