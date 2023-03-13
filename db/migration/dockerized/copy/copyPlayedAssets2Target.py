#!/usr/bin/env python3
#Author: skondla@me.com
#purpose: Copy 6 months Customers StreamedAsset data to Target PostgreSQL dB.
# -*- coding: utf-8 -*-

import pymysql, re
#import setEnv
import os, sys, psycopg2, uuid, datetime, json, requests
import utils

def copyStreamedAssetData():
    #setEnv.setEnv()
    mypassword = utils.getPassword(os.environ['spassword'],os.environ['region'])
    pgpassword = utils.getPassword(os.environ['tpassword'],os.environ['region'])
    
    try:
        myconn = pymysql.connect(host=os.environ['shost'], 
                                           port=int(os.environ['sport']), 
                                           user=os.environ['suser'],
                                           password=mypassword, 
                                           #password=os.environ['spassword'], 
                                           database=os.environ['sdatabase'])
        pgconn = psycopg2.connect(user=os.environ['tuser'],
                                          #password=os.environ['tpassword'],
                                          host=os.environ['thost'], 
                                          password=pgpassword,
                                          port=int(os.environ['tport']), 
                                          database=os.environ['tdatabase'])
    
        mycursor = myconn.cursor()
        pgcursor = pgconn.cursor()
        myquery = os.environ['squery']
        tag = os.environ['tag']
        currtime = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        #print('myquery: ', myquery)
        #pgquery = "insert into shortTermBookmarks values (%s, %s, %s, %s, %s)"
        pgquery = "insert into shortTermBookmarks values (%s, %s, %s, %s, %s, %s, %s)"
        
        #myInsStatusQry = "insert into my_control_pa_migration (currtime,host,batch,status) values (%s, %s, %s, %s)"
        #myInsertStatus = (currtime,os.environ['shost'],tag,'Started')
        #mycursor.execute(myInsStatusQry,myInsertStatus)
        #myconn.commit()

        pgInsStatusQry = "insert into pg_control_pa_migration (currtime,host,batch,status) values (%s, %s, %s, %s)"
        pgInsertStatus = (currtime,os.environ['thost'],tag,'Started')
        pgcursor.execute(pgInsStatusQry,pgInsertStatus)
        pgconn.commit()

        #myInsErrQry = "insert into my_control_pa_migration (currtime,host,batch,error) values (%s, %s, %s, %s)"
        pgInsErrQry = "insert into pg_control_pa_migration (currtime,host,batch,error) values (%s, %s, %s, %s)"

        mycursor.execute(myquery)

        """ In order to avoid large memory allocation on a big table 
        instead of using fetchall(), use fetchmany() to control fetching number 
        of rows to make retrieval of resultset faster and memory allocation efficient."""

        for myrow in iter_row(mycursor, 25000):
            #values=[myrow[0],myrow[1],myrow[2],myrow[3],myrow[4]]
            accountId = myrow[0]
            #profileId = 'default'
            profileId = myrow[1]
            tenantId = myrow[2]
            assetId = myrow[3]
            assetPos = myrow[4]
            bookmarkTime = myrow[5]
            
            #added this line below to bypass null value for bookmarkSecs (target table asset_pos is not null)
            if accountId==None:
                accountId = str(uuid.uuid1())
            if tenantId==None:
                tenantId = str(uuid.uuid1())
            if assetPos==None:
                assetPos = 0

            #print(accountId, profileId, assetId, assetPos, bookmarkTime)
            #print(myrow)
            #pgInsert = (accountId,profileId,assetId, assetPos, bookmarkTime)
            pgInsert = (accountId,profileId,tenantId, assetId, assetPos, bookmarkTime,tag)
            pgcursor.execute(pgquery,pgInsert)
            pgconn.commit()

        #pgconn.commit()
    #except Error as e:
        #print(e)
    except (Exception,pymysql.Error) as myError:
        #currtime = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")    
        #myInsErr = (currtime,os.environ['shost'],tag,myError)
        #mycursor.execute(myInsErrQry,myInsErr)
        slackPost(os.environ['shost'],tag,myError, "MySQL Error of")
        sendEmail(os.environ['thost'],tag,pgError) 
        #myconn.commit()
        print ("Error selecting from StreamedAsset table DB host: " \
            + os.environ['shost'], myError)

    except (Exception, psycopg2.Error) as pgError:
        currtime = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")    
        pgInsErr = (currtime,os.environ['thost'],tag,pgError)
        pgcursor.execute(pgInsErrQry,pgInsErr)
        slackPost(os.environ['thost'],tag,pgError, "Postgres Error of")
        sendEmail(os.environ['thost'],tag,pgError)   
        print ("Error inserting into shortTermBookmarks table DB host: " \
            + os.environ['thost'], pgError)

    finally:
        #myInsertStatus = (currtime,os.environ['shost'],tag,'Ended')
        #mycursor.execute(myInsStatusQry,myInsertStatus)
        #myconn.commit()
        pgInsertStatus = (currtime,os.environ['thost'],tag,'Ended')
        pgcursor.execute(pgInsStatusQry,pgInsertStatus)
        pgconn.commit()
        pgcursor.close()
        mycursor.close()
        pgconn.close()
        myconn.close()

def iter_row(mycursor, size):
    while True:
        rows = mycursor.fetchmany(size)
        if not rows:
            break
        for row in rows:
            yield row

def slackPost(*args):
    slackPost(os.environ['thost'],tag,pgError, "Postgres Error of")
    today = datetime.datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
    webhook_url = 'https://hooks.slack.com/services/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' 
    slack_data = {"channel": "@skondla", "username": "StreamedAsset Migration", 'text': today + ": " + args[3] + "Host: " + args[0] + " Tag: " + \
            args[1] + " Error: " + args[2] + \
            " for dB Endpoint: "  + args[1], "icon_emoji": ":man-biking:"}

    region = os.environ['region']
    response = requests.post(
    webhook_url, data=json.dumps(slack_data),
    headers={'Content-Type': 'application/json'}
    )
    if response.status_code != 200:
       raise ValueError(
        'Request to slack returned an error %s, the response is:\n%s'
        % (response.status_code, response.text)
       )    

def sendEmail(*args):
        with open('/app/email_distro', 'r') as f:
	        email_distro = f.read()
        os.system("echo Migration: " + args[0] + " is " + args[2] + \
                 " for dB: "  + args[1] + "|mailx -s 'PA MIGRATION status'" + email_distro)

if __name__ == "__main__":
    copyStreamedAssetData()

