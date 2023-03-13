#!/bin/bash
#Author: skondla@me.com
#Purpose run Docker container to upload PlayedAsset data to S3 bucket

if [ $# -lt 2 ];
then
    echo "USAGE: bash $0 [containerName bucketName"]
    echo "example: $ bash dockerRunLoadPA2S3.sh loadbookmarks_prod_week1 cp-prod-eu-bookmarks-parallel"
    echo "Please enter Constainer Name.  !!!Exiting !!!"
    exit 1
fi

containerName=${1}
BUCKET_NAME=${2}

#Remove old container if exists
if [[ `docker ps -a | grep ${containerName} | awk '{print $1}'|wc -l` -ge 1 ]]; then
	docker rm `docker ps -a | grep ${containerName} | awk '{print $1}'`
fi

AWS_ACCESS_KEY_ID=`cat ~/.aws/credentials|grep aws_access_key_id | awk '{print $3}'`
AWS_SECRET_ACCESS_KEY=`cat ~/.aws/credentials|grep aws_secret_access_key | awk '{print $3}'`
REGION=`aws configure get region`
echo "REGION: ${REGION}"
#BUCKET_NAME=cp-qa2-us-bookmarks


docker run \
 -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
 -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
 -e BUCKET_NAME=${BUCKET_NAME} \
 -e REGION=${REGION} -d \
 -p 3301:3306 \
 --env-file ./env.sh \
 --name ${containerName} loadpa2s3

# -h `hostname -i` \
# --name loadbookmarks loadpa2s3
