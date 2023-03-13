#!/usr/bin/env python3
#Author: skondla@me.com
#purpose: Load Cloffice PlayedAsset data to S3 by account_id
# -*- coding: utf-8 -*-

#import boto3
#import MySQLdb
#import psycopg2
import sys
#from botocore.client import ClientError
from s3Admin import createS3, uploadS3, checkS3,encryptS3
import pymysql
import pandas
import re
#import setEnv
import os
import utils

def checkBucket(bucketName,region):
    bucketStatus = checkS3().check_bucket(bucketName)
    if bucketStatus:
        print("Bucket: " + bucketName + " exists, Don't create")
    else:
        if 'us-east-1' in region:
            createS3().createBucketUS(bucketName)
            createS3().createBucketPolicy(bucketName)
            encryptS3().encryptBucket(bucketName)
        else:
            createS3().createBucket(bucketName,region)
            createS3().createBucketPolicy(bucketName)
            encryptS3().encryptBucket(bucketName)

def readPlayedAssetData(bucketName):
    #setEnv.setEnv()
    try:

        mypassword = utils.getPassword(os.environ['spassword'],os.environ['region'])
        conn = pymysql.connect(host=os.environ['shost'], 
                port=int(os.environ['sport']), 
                user=os.environ['suser'], 
                password=mypassword,
                #password=os.environ['spassword'], 
                database=os.environ['sdatabase'])

        cursor1 = conn.cursor()
        cursor2 = conn.cursor()
        #query1 = "select distinct(subscriberIdentityGuid) from PlayedAsset"
        query1 = os.environ['squery1']
        query2 = os.environ['squery2']
        #query2 = "select assetGuid as asset_id, bookmarkSecs as position, UNIX_TIMESTAMP(lastUpdated) as position_epoch from PlayedAsset where subscriberIdentityGuid = %s"
        cursor1.execute(query1)

        for subscriberIdentityGuid in iter_row(cursor1, 5000):
            cursor2.execute(query2,subscriberIdentityGuid)
            #results = pandas.read_sql_query(query2 %email, conn)
            results = pandas.read_sql_query(query2, conn,params = subscriberIdentityGuid)
            subscriberIdentityGuid=re.sub("[\'\,\(\)]","",str(subscriberIdentityGuid))
            #fileName= "data/" + str(email) + "-bookmarks.txt"
            fileName= "bookmarks.txt"
            fileAlias=str(subscriberIdentityGuid) + "/default/" + fileName
            results.to_csv(fileName, index=False)
            #results.to_csv("data/" + str(email) + "-bookmarks.txt", index=False)
        
    except (Exception,pymysql.Error) as myError:
        print ("Error selecting from PlayedAsset table DB host: " \
            + os.environ['shost'], myError)
    
    finally:
        cursor2.close()
        cursor1.close()
        conn.close()    

def iter_row(mycursor, size):
    while True:
        rows = mycursor.fetchmany(size)
        if not rows:
            break
        for row in rows:
            yield row

def uploadToS3Bucket():
    pass

if __name__ == "__main__":
    if len(sys.argv) < 3:
        """ Enter Arguments """
        print('Please Enter S3 Bucket Name and Region.  \n !!!Exiting !!!')
        exit()
    else:
        #checkBucket(sys.argv[1],str(sys.argv[2]))
        bucketName = sys.argv[1]
        region = sys.argv[2]
        region = os.environ['region']
        checkBucket(bucketName,region)
        readPlayedAssetData(bucketName)


