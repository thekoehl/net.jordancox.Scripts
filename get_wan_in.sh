first_in=`/usr/bin/curl -s -S http://user:pass@192.168.1.1/fetchif.cgi?vlan1 | /bin/egrep "vlan1" | /bin/egrep -o "\:[0-9]+" | /bin/egrep -o "[0-9]+"`
/bin/sleep 60
second_in=`/usr/bin/curl -s -S http://user:pass2@192.168.1.1/fetchif.cgi?vlan1 | /bin/egrep "vlan1" | /bin/egrep -o "\:[0-9]+" | /bin/egrep -o "[0-9]+"`
let final_value=(second_in-first_in)/60/1024
let val=`/bin/echo $final_value | /bin/egrep -o "[0-9]+"`

/usr/bin/curl -d "data_point[value]=$val&sensor[name]=Server%20-%20Router%20-%20Inbound&user[api_key]=&data_point[reporter]=`hostname`&data_point[units]=Kbytes" http://monocle.phantomdata.com/data_points
