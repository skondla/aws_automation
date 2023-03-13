#!/bin/bash

if [ $# -lt 1 ];
then
    echo "USAGE: bash $0 [bucketName"]
    echo "example: $ bash bucketObjCount.sh cp-prod-eu-bookmarks"
    echo "Please enter Bucker Name.  !!!Exiting !!!"
    exit 1
fi

bucketName=${1}

#aws s3 ls s3://cp-prod-eu-bookmarks/ --recursive | wc -l 
aws s3 ls s3://${bucketName}/ --recursive --summarize | grep "Total Objects:"
