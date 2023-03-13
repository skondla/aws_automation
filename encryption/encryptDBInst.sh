#!/bin/bash
#Author: Sudheer Kondla, skondla@me.com
if [ $# -lt 1 ];
then
    echo "USAGE: bash $0 [DB_ENDPOINT"]
    echo "example: $ ./encryptDBInst.sh dbadmin-muti-region-aurora-poc-eu"
    echo "Please enter DB Instance Name.  !!!Exiting !!!"
    exit 1
fi
aws=/usr/local/bin/aws
TODAY=`date +'%Y%m%d-%H%M%S'`
dbEndPoint=$1
currentTime=`date '+%Y%m%d'%M%S`
tagName=snapshot-$currentTime
snapShotName=$dbEndPoint-unencrypted-$TODAY
targetSnapName=$dbEndPoint-encrypted-$TODAY

#For Encrypted Snaphot

kmsKeyId=`$aws kms list-aliases | grep -A 3 rds-encrypt | awk '{print $2}' | cut -f2 -d'"' | sed '/^$/d' | tail -1`

cd ~/jobs

function desc_db_instance() {
 python -c "import rdsAdmin; rdsAdmin.rds_desc_db_instances('$1')" >$1.json; /usr/local/bin/js-beautify $1.json
}

function renameDBInstance() {
 $aws rds modify-db-instance --db-instance-identifier $1 --new-db-instance-identifier $2 --apply-immediately
 echo "Renameing db Instance $1 to $2. Wait upto 300 seconds.."
 sleep 300
}

function stopInstance() {
 echo "Stopping db Instance $1"
 $aws rds stop-db-instance --db-instance-identifier $1 >  stop-$1.json ; /usr/local/bin/js-beautify stop-$1.json
}

function renameDBInstanceNew() {
 #bash modify_db_instance.sh $1 new-db-instance-identifier $2 N
 $aws rds modify-db-instance --db-instance-identifier $1 --new-db-instance-identifier $2 --apply-immediately
 echo "Renameing db Instance $1 to $2. Wait upto 300 seconds.."
 sleep 300

}

function statusDBInstance() {
 STATUS=`python -c "import rdsAdmin; rdsAdmin.rds_desc_db_instances('$1')" >$1.json ; /usr/local/bin/js-beautify $targetSnapName.json | grep DBInstanceStatus | awk '{print $3}'  | cut -f2 -d"'"`
 echo $STATUS 
}

function statusDBSnapshot() {
 STATUS=`python -c "import rdsAdmin; rdsAdmin.describe_db_snapshots('$1')" >$1.json ; /usr/local/bin/js-beautify $1.json | grep Status | grep -v HTTP | awk '{print $3}'  | cut -f2 -d"'"`
echo $STATUS 
}

function modifyDBSecurityGrp() {
 $aws rds modify-db-instance --db-instance-identifier $1 --vpc-security-group-ids $2 --apply-immediately
 sleep 180
}

$aws rds describe-db-instances  --db-instance-identifier $dbEndPoint | egrep '(DBSubnetGroupName|VpcSecurityGroupId)' | awk '{print $2}' | cut -f2 -d'"' > $dbEndPoint-setting.log
dbSecurityGrp=`cat $dbEndPoint-setting.log | head -1`
dbSubnetGrp=`cat $dbEndPoint-setting.log | tail -1`
echo "snapShotName: $snapShotName"
python -c "import rdsAdmin; rdsAdmin.rds_create_db_snapshot('$snapShotName', '$dbEndPoint', '$tagName')" > $snapShotName.json
echo "Creating snapshot $snapShotName for db Instance $dbEndPoint. Wait upto 720 seconds.."
sleep 720
echo "targetSnapName: $targetSnapName"
python -c "import rdsAdmin; rdsAdmin.encrypt_db_snapshot('$snapShotName','$targetSnapName','$kmsKeyId')" > copySnapshot-$targetSnapName.json
echo "Copying snapshot $targetSnapName for db Instance $dbEndPoint  encryption. Wait upto 1800 seconds.."
#exit 1
sleep 1800
for i in {1..3}
do
  echo "checking of snapshot $targetSnapName whether it is in available state"
  echo "Encrypted Snapshot Staus: `statusDBSnapshot $targetSnapName`" 

  if [[ `statusDBSnapshot $targetSnapName`  == 'available' ]]; then
	echo "snapshot $targetSnapName is in AVAILABLE state"
	if [[ `statusDBInstance $targetSnapName`  == 'available' ]]; then
	   echo "encrypted DBInstance $targetSnapName is in AVAILABLE state"
	else
 	   python -c "import rdsAdmin; rdsAdmin.restore_db_instance_from_db_snapshot('$targetSnapName','$targetSnapName',False,'$dbSubnetGrp')" > restore-$targetSnapName.json
           sleep 2400
	   echo "Restoring snapshot $targetSnapName for db Instance $dbEndPoint  encryption. Wait upto 2400 seconds.."
	fi
	for j in {1..2}
	do
	  if [[ `statusDBInstance $targetSnapName`  == 'available' ]]; then
	      echo "encrypted DBInstance $targetSnapName is in AVAILABLE state"	
	      #bash modify_db_instance.sh $targetSnapName vpc-security-group-ids $dbSecurityGrp N	
	      modifyDBSecurityGrp $targetSnapName $dbSecurityGrp	
	      echo "Changing db Security group to $dbSecurityGrp for db Instance $targetSnapName, wait up to 180 seconds.."
	      #sleep 180	
	      desc_db_instance $targetSnapName
	      renameDBInstance $dbEndPoint $dbEndPoint-old
	      renameDBInstanceNew $targetSnapName $dbEndPoint
	      stopInstance $dbEndPoint-old	
	   else
 	      echo "Restored Instance $targetSnapName is not ready.., waiting another 240 seconds"
	      #exit 0
	      sleep 240	
	   fi
	done 
	exit 0
  else
	echo "Encrypted snapshot $targetSnapName is still being created ..., waiting another 300 seconds"
	sleep 300
  fi
done
