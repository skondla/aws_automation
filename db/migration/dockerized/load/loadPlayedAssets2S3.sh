#!/bin/bash
#Author: skondla@me.com
#Purpose run Docker container to upload PlayedAsset data to S3 bucket

python loadPlayedAssets2S3.py ${BUCKET_NAME} ${REGION}
