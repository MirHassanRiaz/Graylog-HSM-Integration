# Graylog-HSM-Integration
This repo is focused at sharing research with the community regarding the automation of HSM socket connections monitoring process and creating alerts if the number of available sockets drop below 50. 

Background: 
Security PINs are an essential piece of security in any payments application. Without PINs no financial trade can happen and these PINs rely heavily on Hardware security modules (HSM) for PIN security.

All HSMs PIN validation requests depend on TCP sockets for PIN security and validation of any payments requests from the app. If the tcp sockets of HSM get full consumed there would be no pin validation requests entertained by HSM meaning a complete business outage. 

Therefore, it is essential for modern Security Operations Centers to monitor the TCP sockets consumption and respond to any throttling then and there before business gets impacted.

Follow the following steps to automate tcp/ socket connection monitoring of Atalla HSM with Graylog

# Manual Process previously performed by an HSM administrator

The way to check HSM socket connections is to manually connect to HSM on specific port for i.e. 9010 and run below command:

<1223#>

Command to check available connections for a specific port

<1223#9010#>

The above command needs to be run manually everytime the socket connection count needs to be checked. In order to automate this, we wrote a bash script that:

Automatically connect to HSM via netcat on port 9010

Runs the command

Captures the timestamp of command execution

And writes it in /var/log/hsm-connection.log 

# Script to check HSM tcp sockets and print logs in /var/log directory for SOC integestion

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

Execution of this script writes below log lines to the above mentioned log lines

![image](https://user-images.githubusercontent.com/53171887/170818613-ee7627fe-7135-4d36-90fd-50cfb03e867b.png)

Now the next step was to send these logs to graylog via rsyslog utility, configuration parameters for which are given below:

input(type="imfile" Tag="hsm-conns-khi" File="/var/log/hsm-connection.log" Facility="local7" Severity="error")
local7.* @@10.10.5.7.:5519

In order to recieve logs on Graylog, we configured an input for HSM connection logs as shown below:

![image](https://user-images.githubusercontent.com/53171887/170818678-9d3bb9a4-0b0b-4f22-96a0-7424172789a9.png)

Next we configured an alert in the scenario where available HSM socket connections drop below 50.

![image](https://user-images.githubusercontent.com/53171887/170818702-890a33f3-eb2e-4d98-9204-a219134c92c2.png)

After manually making telnet sessions to decrease the number of available socket connections and trigger the alert notification, we successfully received an email alert as shown below:

![image](https://user-images.githubusercontent.com/53171887/170818978-77092b5e-79da-4780-80d2-28b005a5b698.png)

# Dashboard for HSM Socket Connections on Graylog

![image](https://user-images.githubusercontent.com/53171887/170819095-210bf7db-392a-4f33-9d9b-2baa07b555d7.png)

So this way our Security Operations Center would be able to achieve the following:

# Golas Achieved: 

1. Get immediate alerts if consumed socket connection exceeds our defined threshold
2. Trigger Incident Resposne Playbook
3. Resolve issues before it converts into a customer compliant/ or call center gets bombarded with requests


