CURL=/usr/bin/curl
EGREP=/bin/egrep
AWK=/usr/bin/awk
val=`$CURL -s -S http://192.168.1.50 | $EGREP "Raw" | $EGREP -o "[0-9]+" | $AWK '{print ((100*$1*5)/1023)-2}'`

/usr/bin/curl -d "data_point[value]=$val&sensor[name]=Temperatures%20-%20Attic&user[api_key]=&data_point[reporter]=`hostname`&data_point[units]=F" http://monocle.phantomdata.com/data_points
