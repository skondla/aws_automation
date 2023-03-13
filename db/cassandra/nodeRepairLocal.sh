#!/bin/bash
#Author: Sudheer Kondla, skondla@Me.com 
#pip install pygments
#pip install jsbeautifier
if [ $# -lt 5 ];
then
    echo "USAGE: $0 [Attribute_name Where_condition Cassandra_Cluster_name AWS_profile{default|prod} key_name]"
	echo "./nodeRepairLocal.sh elasticIP appId Cass-tve-pre default CL-KP-VPC-IAD-NFL"
	echo "./nodeRepairLocal.sh hostname appId Cass-tve-prod prod nfl-prod-key-global-ops"
	exit 1
fi
Attribute_Name=$1
Where_condition=$2
Cassandra_Cluster_name=$3
Profile=$4
keyName=$5
# aws configure --profile prod set region us-east-1
cd /home/admin/admin/scripts/cassandra
./qrySDB.py $Attribute_Name $Where_condition $Cassandra_Cluster_name $Profile > output/nodeRepairLocal-nodes-$Cassandra_Cluster_name-$Attribute_Name.json
/usr/local/bin/js-beautify output/nodeRepairLocal-nodes-$Cassandra_Cluster_name-$Attribute_Name.json | grep Value | awk {'print $3}' | cut -f 2 -d "'" > $Cassandra_Cluster_name.list

eval $(ssh-agent)
#pass=$(cat $2) 
pass=$(cat /home/admin/.ssh/passphrases)

/usr/bin/expect << EOF
  spawn ssh-add /home/admin/.ssh/$keyName.pem
  expect "Enter passphrase"
  send "$pass\r"
  expect eof
EOF

for node in `cat $Cassandra_Cluster_name.list`; do echo "node: $i";  /usr/bin/ssh -i /home/admin/.ssh/$keyName.pem -o "StrictHostKeyChecking no" admin@$node 'nodetool repair --full -local';done


