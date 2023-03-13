#!/bin/bash
#Author: skondla@me.com
for host in `cat load.hosts` ; do echo "host:$host"; ssh -i ~/.ssh/dbadmin-np.pem admin@$host 'sudo crontab -l'; done
