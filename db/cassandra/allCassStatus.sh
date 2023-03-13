#!/bin/bash
#Author: Sudheer Kondla, skondla@me.com
#Purpose: To check the status of all cassandra nodes in all clusters

for cluster in `cat cass-clusters.list|awk '{print $1}'`
do
	profile=`cat cass-clusters.list| grep $cluster|awk '{print $2}'`
	for node in `/home/admin/admin/scripts/cassandra/qrySDB.sh hostname appId $cluster $profile` 
	#for node in `/home/admin/admin/scripts/cassandra/qrySDB.sh hostname appId Cass-np default` 
	do
		/usr/bin/ssh -i ~/.ssh/CL-KP-VPC-IAD-NFL.pem admin@$node 'nodetool status' > $cluster.nodes.status
		if [ $? = 0 ]; then
			echo "IP: $node, Command is successful."
			if [ `cat $cluster.nodes.status | tail -8 | awk '{print $1, " ",  $2}' | grep 'DN' |wc -l` -ge 1 ]; then
				cat $cluster.nodes.status | tail -8 | awk '{print $1, " ",  $2}' | grep 'DN' > $cluster.nodes.down
				for node_down in `cat $cluster.nodes.down| awk '{print $2}'`
				do
					echo "NODE: $node_down is down"
					echo "NODE: $node_down is down" | mailx -s "Cassandra Node Down!" Sudheer.Kondla@gmail.com 
				done	
			fi
			if [ `cat $cluster.nodes.status | tail -8 | awk '{print $1, " ",  $2}' | egrep '(UL|UJ|UM|DL|DM)' |wc -l` -ge 1 ]; then
				cat $cluster.nodes.status | tail -8 | awk '{print $1, " ",  $2}' |  egrep '(UL|UJ|UM|DL|DM)' > $cluster-nodes.changing
				for node_changing in `cat $cluster-nodes.changing | awk '{print $2}'`
				do
					echo "NODE: $node_changing is changing status - either joining/leaving/moving"
					echo "NODE: $node_changing is changing status - either joining/leaving/moving" | mailx -s "Cassandra Node Down!" Sudheer.Kondla@gmail.com	
				done
			fi
			#exit
		else
			echo "IP $node, continue with next node"
		fi
	done
done	
