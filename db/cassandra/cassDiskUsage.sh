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
DISK_USAGE_LOG=/home/admin/admin/scripts/cassandra/output/$cassClusters.diskUsage.log
DISK_WARNING=/home/admin/admin/scripts/cassandra/output/$cassClusters.lowStorage.log
SCRIPT_DIR=/home/admin/admin/scripts/cassandra

echo "####################################" >> $DISK_USAGE_LOG
echo "Date: `date`" >> $DISK_USAGE_LOG
echo "####################################" >> $DISK_WARNING
echo "Date: `date`" >> $DISK_WARNING

cd $SCRIPT_DIR
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
	   else	
		CASS_DISK_USED=`/usr/bin/ssh -i ~/.ssh/$keyName.pem -o "StrictHostKeyChecking no" admin@$node df -h | grep scratch|awk '{print $5}'|cut -f 1 -d "%"`
		#CASS_DISK_USED=`/usr/bin/ssh -i ~/.ssh/$keyName.pem admin@$node df -h | grep scratch|awk '{print $5}'|cut -f 1 -d "%"`
		echo "CASS_DISK_USED: $CASS_DISK_USED on $node in $cluster" >> $DISK_USAGE_LOG
		if [ $CASS_DISK_USED -ge 50 ]; then
		   echo "Disk Usage: $CASS_DISK_USED on $node in $cluster" >> $DISK_WARNING
		   if [ $pageOut = "Y" ]; then
			echo "Disk Usage: $CASS_DISK_USED on $node in $cluster" | mailx -s "Disk Usage: $CASS_DISK_USED on $node in $cluster" $EMAIL_PAGEOUT
			/usr/bin/curl -X POST \
			 --data-urlencode 'payload={"channel": "#db-alerts", "username": "webhookbot", "text": "'"$DATETIME: Disk Usage: $CASS_DISK_USED on $node in $cluster"'", "icon_emoji": ":dog_run:"}' https://hooks.slack.com/services/AWWFTYU/AMTRTOOZT/s1qgw7Wb2gEZv5vXvCwYdoMFgEOY9
		   else
			echo "Disk Usage: $CASS_DISK_USED on $node in $cluster" | mailx -s "Disk Usage: $CASS_DISK_USED on $node in $cluster" $EMAIL
		   fi				
		else
		   echo "Disk usage is OK" > /dev/null
		fi	
	   fi
	done
done	
