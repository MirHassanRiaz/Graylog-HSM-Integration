#!/bin/bash

ip="10.10.5.6"
port="9010"

d=$(date)
hsm_conn_res=$(echo "<1223#>" | nc -n $ip $port -w 1)
avail_sockets=$(echo $hsm_conn_res | cut -d "#" -f 2)
total_sockets=$(echo $hsm_conn_res | cut -d "#" -f 3)
consumed_sockets=$((total_sockets-avail_sockets))
log=$d" "$consumed_sockets" TCP socket connections are consumed out of "$total_sockets" on HSM Host: "$ip":"$port"  "$hsm_conn_res
echo $log >> /var/log/hsm-connection.log
sleep 1s
