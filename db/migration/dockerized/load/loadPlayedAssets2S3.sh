#!/bin/bash
#Author: skondla@me.com
#Purpose run Docker container to upload StreamedAsset data to S3 bucket

python loadStreamedAssets2S3.py ${BUCKET_NAME} ${REGION}
