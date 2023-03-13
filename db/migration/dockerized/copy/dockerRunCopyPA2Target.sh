#!/bin/bash
#Author: skondla@me.com
#Purpose run Docker container to upload StreamedAsset data to S3 bucket

if [ $# -lt 1 ];
then
    echo "USAGE: bash $0 [containerName"]
    echo "example: $ bash dockerRunCopyPA2Target.sh copybookmarks_prod" 
    echo "Please enter Constainer Name.  !!!Exiting !!!"
    exit 1
fi

containerName=${1}

#Remove old container if exists
if [[ `docker ps -a | grep ${containerName} | awk '{print $1}'|wc -l` -ge 1 ]]; then
	docker rm `docker ps -a | grep ${containerName} | awk '{print $1}'`
fi

AWS_ACCESS_KEY_ID=`cat ~/.aws/credentials|grep aws_access_key_id | awk '{print $3}'`
AWS_SECRET_ACCESS_KEY=`cat ~/.aws/credentials|grep aws_secret_access_key | awk '{print $3}'`
REGION=`aws configure get region`
#BUCKET_NAME=cp-prod-us-bookmarks


docker run \
 -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
 -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
 -e REGION=${REGION} -d \
 -p 3300:3306 -p 5400:5432 \
 --env-file ./env.sh \
 --name ${containerName} copypa2target
