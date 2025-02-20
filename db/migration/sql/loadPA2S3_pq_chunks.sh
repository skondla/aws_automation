#!/bin/bash
#Author: skondla@me.com

if [ $# -lt 3 ];
then
    echo "USAGE: bash $0 [dbEndPoiint month monthyear"]
    echo "example: bash loadPA2S3_pq_chunks.sh cp-prod-pamigrate-pq.abcfr72fgsg3w.us-west-2.rds.amazonaws.com 28 201708" 
    exit 1
fi
dbEndPoiint=${1}
month=${2}
monthyear=${3}
cd /home/admin/admin/mysql/migrate/pa2S3/load
MYSQL_PWD=`cat ~/.password/mySQLPassword.lst | grep 'custusr' | awk '{print $5}'`

/usr/bin/time mysql \
 -A -f -h${dbEndPoiint} \
 -ucustusr -p'password' custusr \
 -e "CALL loadPA2S3_chunks_monthly(${month},${monthyear});" > /data2/dumps/loadPA2S3_chunks_monthly_${month}.log 
 
#-e "CALL loadPA2S3_chunks_monthly(28,201708);" > /data2/dumps/loadPA2S3_chunks_monthly_28.log 

