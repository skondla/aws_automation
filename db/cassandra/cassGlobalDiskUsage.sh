#!/bin/bash
#Author: Sudheer Kondla, skondla@me.com
#Purpose: Check Cassndra Clusters Disk Usage

if [ $# -lt 3 ];
then
    echo "USAGE: $0 {list_of_cass_clusters keyName pageOut[Y/N]}"
    echo "Example: ./cassDiskUsage.sh cluster_list KEY_NAME"
    echo "Example: ./cassDiskUsage.sh cass-clusters-prod-us.list nfl-prod-key-global-ops Y"
    exit 1
fi

cassClusters=$1
keyName=$2
EMAIL=`cat /home/admin/admin/scripts/cassandra/email_distro`
EMAIL_PAGEOUT=`cat /home/admin/admin/scripts/cassandra/email_distro_sms`
DATE=`date +'%Y%m%d'`
DISK_USAGE_LOG=/home/admin/admin/scripts/cassandra/output/$cassClusters.diskUsage.log.$DATE
DISK_WARNING=/home/admin/admin/scripts/cassandra/output/$cassClusters.lowStorage.log.$DATE
SCRIPT_DIR=/home/admin/admin/scripts/cassandra

echo "####################################" >> $DISK_USAGE_LOG
echo "Date: `date`" >> $DISK_USAGE_LOG
echo "####################################" >> $DISK_WARNING
echo "Date: `date`" >> $DISK_WARNING

cd $SCRIPT_DIR
eval $(ssh-agent)
#pass=$(cat $2)
pass=$(cat /home/admin/.ssh/passphrases)

/usr/bin/expect << EOF
  spawn ssh-add /home/admin/.ssh/$keyName.pem
  expect "Enter passphrase"
  send "$pass\r"
  expect eof
EOF

sendEmail() {
    inst=${1}
    lag=${2}
    subject="Replica Lag"
    message="Replica ${inst} is lagging ${lag} ms"
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

for cluster in `cat $cassClusters|awk '{print $1}'`
do
	profile=`cat $cassClusters| grep $cluster|awk '{print $2}'`
	for node in `/home/admin/admin/scripts/cassandra/qrySDB.sh hostname appId $cluster $profile` 
	do
	   #This is in US, cannot reach EU cluster nodes , add a black list
	   CIDR=`echo $node | cut -d"." -f1-3`
	   echo "CIDR: $CIDR"	
	   if [[ `echo $node | cut -d"." -f1-3` = "10.93.245" ]]; then
		continue
		#exit
	   else	
		CASS_DISK_USED=`/usr/bin/ssh -i ~/.ssh/$keyName.pem -o "StrictHostKeyChecking no" admin@$node df -h | grep scratch|awk '{print $5}'|cut -f 1 -d "%"`
		#CASS_DISK_USED=`/usr/bin/ssh -i ~/.ssh/$keyName.pem admin@$node df -h | grep scratch|awk '{print $5}'|cut -f 1 -d "%"`
		echo "CASS_DISK_USED: $CASS_DISK_USED on $node in $cluster" >> $DISK_USAGE_LOG
		if [ $CASS_DISK_USED -ge 50 ]; then
		   echo "Disk Usage: $CASS_DISK_USED on $node in $cluster" >> $DISK_WARNING
		   /usr/bin/curl -X POST --data-urlencode 'payload={"channel": "#db-alerts", "username": "CassandraStorage", "text": "'"$DATETIME Disk Usage: $CASS_DISK_USED on $node in $cluster"'", "icon_emoji": ":ghost:"}' https://hooks.slack.com/services/AWWFTYU/AMTRTOOZT/s1qgw7Wb2gEZv5vXvCwYdoMFgEOY9
		   if [[ $pageOut = "Y" ]]; then
			#echo "Disk Usage: $CASS_DISK_USED on $node in $cluster" | mailx -s "Disk Usage: $CASS_DISK_USED on $node in $cluster" $EMAIL_PAGEOUT
			sendEmail "Disk Usage: $CASS_DISK_USED on $node in $cluster" "Disk Usage%: $CASS_DISK_USED on $node in $cluster"
		   else
			#echo "Disk Usage: $CASS_DISK_USED on $node in $cluster" | mailx -s "Disk Usage: $CASS_DISK_USED on $node in $cluster" $EMAIL
			sendEmail "Disk Usage: $CASS_DISK_USED on $node in $cluster" "Disk Usage: $CASS_DISK_USED on $node in $cluster"
		   fi				
		else
		   echo "Disk usage is OK" > /dev/null
		fi	
	   fi
	done
done	
ps -ef|grep ssh-agent | awk '{print $2}' | xargs kill -9
