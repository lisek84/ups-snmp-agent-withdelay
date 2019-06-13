#!/bin/bash
## This script will generate BASIC credential configuration file. It uses SAME LOGIN and PASSWORD for ALL machines configured
## in config.cfg.
##
## It may be useful if you have same or similar passwords for your IPMI configuration.


if [ "$#" -lt '1' ]; then
	clear
	echo ----------------------------------------------------------------
	echo - Please provide LOGIN and PASSWORD to shutdown machines       -
	echo -                                                              -
	echo -  $0 - LOGIN PASSWORD                -
	echo ----------------------------------------------------------------
	exit 1
fi

# Reading configuration files
cd `dirname $0`
. config.cfg

ILOGIN="$1"
IPASSWORD="$2"
echo "## HERE YOU SHOULD CONFIGURE ACCESS CREDENTIALS TO YOUR IPMI BOARDS" >credentials.cfg 
for machine in `declare -p | grep shutdowngroup | cut -d'"' -f2 | tr " " "\n" | sort -n | uniq`; do echo $machine $ILOGIN $IPASSWORD; done >>credentials.cfg
