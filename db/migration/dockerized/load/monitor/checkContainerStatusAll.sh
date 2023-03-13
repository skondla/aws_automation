#!/bin/bash
#Author: skondla@me.com
for host in `cat load.hosts` ; do echo "host:$host"; ssh -i ~/.ssh/dbadmin-np.pem admin@$host 'sudo docker ps -a'; done
