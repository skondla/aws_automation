#!/usr/bin/env python 
#Author: Sudheer Kondla, sudheer.kondla@gmail.com , 03/20/2017
import boto3
import sys

if len(sys.argv) < 5:
  print ("You must set argument!!! Attribute_name, Where_filter Cassandra_Cluster_name profile")
  sys.exit(0)

cass_attrib1=str(sys.argv[1])
cass_filter=str(sys.argv[2])
cass_attribute=str(sys.argv[3])
s = boto3.Session(profile_name=sys.argv[4])
print(cass_attrib1)
print(cass_filter)
print(cass_attribute)
print(s)


sql_cmd="select %s from `InstanceIdentity` where %s='%s'" % (cass_attrib1,cass_filter,cass_attribute)
print(sql_cmd)


if __name__ == '__main__':
	session = boto3.Session(profile_name=sys.argv[4])
	# Any clients created from this session will use credentials
	# from the [default] section of ~/.aws/credentials.
	client = session.client('sdb')
	response = client.select(
	SelectExpression=sql_cmd,
	ConsistentRead=True
)

print (response)