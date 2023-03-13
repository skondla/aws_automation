#!/bin/bash
#Author: skondla@me.com
for host in `cat load.hosts` ; do echo "host:$host"; ssh -i ~/.ssh/dbadmin-np.pem admin@$host 'ps aux | head -1 && ps aux | grep  cp-bookmark-monthly-container-local2 | grep -v grep'; done
