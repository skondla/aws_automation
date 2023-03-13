#!/bin/bash
#Author: Sudheer Kondla, skondla@Me.com 
#pip install pygments
#pip install jsbeautifier
if [ $# -lt 4 ];
then
    echo "USAGE: $0 [Attribute_name Where_condition Cassandra_Cluster_name AWS_profile{default|prod}]"
	echo "./qrySDB.sh elasticIP appId Cass-tve-pre default"
	echo "./qrySDB.sh hostname appId Cass-tve-prod prod-us"
	exit 1
fi
Attribute_Name=$1
Where_condition=$2
Cassandra_Cluster_name=$3
Profile=$4
#aws configure --profile $Profile set region us-east-1
cd /home/admin/admin/scripts/cassandra
./qrySDB.py $Attribute_Name $Where_condition $Cassandra_Cluster_name $Profile > output/qrySDB-nodes-$Cassandra_Cluster_name-$Attribute_Name.json
/usr/local/bin/js-beautify output/qrySDB-nodes-$Cassandra_Cluster_name-$Attribute_Name.json | grep Value | awk {'print $3}' | cut -f 2 -d "'"


