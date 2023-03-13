#!/bin/bash
#Author: Sudheer Kondla, skondla@me.com 
#Purpose: Check Cassandra cluster nodes

if [ $# -lt 4 ];
then
    echo "USAGE: $0 {Cassandra_cluster_name Profile_Name[default/prod] KEY_NAME PAGEOUT[Y/N]}"
    #echo "${red}USAGE: $0 {Cassandra_cluster_name Profile_Name[default/prod]} ${reset}"
    echo "Example: ./cassStatus.sh Cass-np  default CL-KP-VPC-IAD-NFL N"
    echo "Example: ./cassStatus.sh Cass-prod-us prod nfl-prod-key-global-ops Y"
    exit 1
fi

cassClustername=$1
profileName=$2
keyName=$3
pageOut=$4
EMAIL=`cat /home/admin/admin/scripts/cassandra/email_distro`
EMAIL_PAGEOUT=`cat /home/admin/admin/scripts/cassandra/email_distro_sms`

sendEmail() {
    subject=${1}
    message=${2}
    /usr/bin/python -c \
     "from sesAdmin import sendEmail; sendEmail('$subject','$message')"
}

sendRawEmail() {
    fileName=${1}
    inst=${2}
    lag=${3}
    subject="Replica Lag"
    message="Replica ${inst} is lagging ${lag} ms"
    echo "message: ${message}"  
    /usr/bin/python -c \
     "from sesAdmin import sendRawEmail; sendRawEmail('$fileName','$subject','$message')"
}

slackMessage() {
	channel=${1}
	message=${2}
	/usr/bin/curl -X POST \
	 --data-urlencode 'payload={
	 "channel": "'"${channel}"'", 
	 "username": "CassandraStatus", 
	 "text": "'"$DATETIME: ${message}"'", 
	 "icon_emoji": ":dog_run:"
	 }' \
	 https://hooks.slack.com/services/AWWFTYU/AMTRTOOZT/s1qgw7Wb2gEZv5vXvCwYdoMFgEOY9
}

cd /home/admin/admin/scripts/cassandra
#bash addKey.sh /home/admin/.ssh/nfl-prod-key-global-ops.pem /home/admin/.ssh/passphrases

eval $(ssh-agent)
#pass=$(cat $2)
pass=$(cat /home/admin/.ssh/passphrases)

/usr/bin/expect << EOF
  spawn ssh-add /home/admin/.ssh/$keyName.pem
  expect "Enter passphrase"
  send "$pass\r"
  expect eof
EOF

for node in `/home/admin/admin/scripts/cassandra/qrySDB.sh hostname appId $cassClustername $profileName` 

do
   if [[ `echo $node | cut -d"." -f1-2` = "10.93" ]]; then
	continue	
   else 	
	/usr/bin/ssh -i /home/admin/.ssh/$keyName.pem -o "StrictHostKeyChecking no" admin@$node 'nodetool status' > $cassClustername-nodes-status
	if [ $? = 0 ];then
		echo "IP: $node, Command is successful." > /dev/null
		if [ `cat $cassClustername-nodes-status | grep DN | awk '{print $1, " ",  $2}' |wc -l` -ge 1 ]; then
			cat $cassClustername-nodes-status | grep DN | awk '{print $1, " ",  $2}' > $cassClustername-nodes-down
			for node_down in `cat $cassClustername-nodes-down| awk '{print $2}'`
			do
				echo "NODE: $node_down is down" > /dev/null
				sendEmail "Cassandra Node Down!, Cluster: $cassClustername" "NODE: $node_down is down from cluster: $cassClustername"
				slackMessage "#db-alerts" "NODE: $node_down is down from cluster: $cassClustername"
			done	
		fi
		if [ `cat $cassClustername-nodes-status | tail -8 | awk '{print $1, " ",  $2}' | egrep '(UL|UJ|UM|DL|DM)' |wc -l` -ge 1 ]; then
	        cat $cassClustername-nodes-status | tail -8 | awk '{print $1, " ",  $2}' |  egrep '(UL|UJ|UM|DL|DM)' > $cluster-nodes.changing
            for node_changing in `cat $cluster-nodes.changing | awk '{print $2}'`
            do
               	echo "NODE: $node_changing is changing status - either joining/leaving/moving" > /dev/null
			 	sendEmail "Cassandra Node Down!, Cluster: $cassClustername" "NODE: $node_down is down from cluster: $cassClustername"
				slackMessage "#db-alerts" "$node_changing is changing status - either joining/leaving/moving"	
            done
        fi
		exit
	else
		echo "IP $node: Cannot connect to $node,  continue with next node"
	fi
   fi 
done
ps -ef|grep ssh-agent | awk '{print $2}' | xargs kill -9


