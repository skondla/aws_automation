#!/usr/bin/env python3
#Author: skondla@me.com

import boto3
import sys

def getPassword(secret_name):
    client = boto3.client('secretsmanager')
    #secret_name = "ott_qa_cma_db_password"
    response = client.get_secret_value(
        SecretId=secret_name
    )
    return response['SecretString']
#return response['SecretString']
#print (response['SecretString'])


if __name__ == "__main__":
    if len(sys.argv) < 2:
        """ Enter Arguments """
        print('Please Enter secret_name.  \n !!!Exiting !!!')
        exit()
    else:
        #print('sys.argv[0]): ' + sys.argv[1])
        print(getPassword(sys.argv[1]))


