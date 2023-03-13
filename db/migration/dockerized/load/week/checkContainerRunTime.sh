#!/bin/bash
#Author: skondla@me.com
#Purpose: Check Docker container run time.

if [ $# -lt 1 ];
then
    echo "USAGE: bash $0 [containerName"]
    echo "example: $ bash checkContainerRunTime.sh loadbookmarks_prod_week1" 
    echo "Please enter Constainer Name.  !!!Exiting !!!"
    exit 1
fi

containerName=${1}

docker container inspect `docker ps -a | grep ${containerName} |awk '{print $1}'` | egrep '(StartedAt|FinishedAt)'
