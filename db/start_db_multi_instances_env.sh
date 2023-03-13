#!/bin/bash
#Author: Sudheer Kondla, 04/30/2017, skondla@me.com
#Purpose: Change DB instance configuration

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
white=`tput setaf 7`
reset=`tput sgr0`

if [ $# -lt 1 ];
then
    	echo "${red}USAGE: $0 [DB_ENV PARAMETER_NAME]"${reset}
	echo "${cyan}Please enter DB environment  !!!Exiting !!!"${reset}
	echo "${yellow}example: $ ./start_db_multi_instances_env.sh dev"${reset}
	echo "${yellow}example: $ ./start_db_multi_instances_env.sh qa"${reset}
	echo "${blue}Reference: http://docs.aws.amazon.com/cli/latest/reference/rds/start-db-instance.html"${reset}
	echo "Instance Name
	--db-instance-identifier (string)
	SYNOPSIS
	  start-db-instance
		--db-instance-identifier <value>
		[--cli-input-json <value>]
		[--generate-cli-skeleton <value>]
	"
	exit 1
fi

dbEnv=$1
/usr/local/bin/aws rds describe-db-instances | grep Address | awk '{print $2}' | cut -f1 -d"."  | grep "\-$dbEnv" | sed -e 's/^"//' -e 's/"$//' > rds-$dbEnv.list
cd /home/admin/jobs
for instance in `cat rds-$dbEnv.list|awk '{print $1}'`
do
   /usr/local/bin/aws rds start-db-instance --db-instance-identifier $instance > output/$instance-started.json
done

