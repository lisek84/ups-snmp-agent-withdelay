#!/bin/bash

# Reading configuration file
cd `dirname $0`
. config.cfg


while :
do
# Looking for "No Such Object" output if snmp server is not responding with this OID. It's normal when you set OID to one of the alarms. 
snmptest=`$snmpwalk -c $community -v$snmpversion $IPaddress $shutdownoid 2>/dev/null`
walkexited=$?

if [ "$connection_fatal" -ne 0 ]; then
       if [ "$walkexited" -ne 0 ]; then
       echo "I'm configured to die if snmp communication fails. Snmp walk exited with error"
       exit 1
       fi
fi



if [[ $snmptest == *"No Such Object available"* ]]; then
        echo "No Such OID. This is OK if OID is one of the alarm OIDs. Setting \"OK\" Answer"
	echo "Also. If you made mistake in configuration of OID, You really don't want me to kill all your machines Huh? :-)"
	continue
fi



# Connecting to SNMP Server and checking actual UPS Status
ups_status=`$snmpwalk -c $community -v$snmpversion $IPaddress $shutdownoid 2>/dev/null|cut -d':' -f2 | xargs | sed -re 's/([0-9])([0-9]{1})($|[^0-9])/\1\2\3/'`

if [ "$ups_status" -eq $normaltrap ]; then sleep $polldelay; continue; else
	if [ "$ups_status" -eq "$batterytrap" ]; then 
		echo ---------------- >>$logfile
		echo `date` >>$logfile
		echo "ALARM I HAVE DETECTED THERE IS NO POWER!!! IF IT WILL NOT COME BACK IN $waittime SECONDS. I WILL BEGIN SHUTING EVERYTHING DOWN" >>$logfile

# Waiting for power come back
		sleep $waittime
		ups_status=`$snmpwalk -c $community -v$snmpversion $IPaddress $shutdownoid 2>/dev/null|cut -d':' -f2 | xargs | sed -re 's/([0-9])([0-9]{1})($|[^0-9])/\1\2\3/'`

		if [ "$ups_status" -eq $normaltrap ]; then echo "UFF. WE GOT THE POWER BACK!!!! NOTHING HAPPENED STEP ASIDE" >>$logfile; continue
		else
		echo "I'm SORRY BUT THERE IS STILL NO POWER. I'M RUNNING SHUTDOWN PROCEDURE NOW!" >>$logfile

		# Checking how many declared groups of servers do I have configured as variables from configuration file.
		numofgroups=`declare -p | grep shutdowngroup | wc -l`

		# Executing Shutdown procedure. This will execute declared script with list of servers as script parameters

			for group in $(seq 1 $numofgroups); do
        			echo Executing Shutdown procedure for the $group group of servers >>$logfile
        			groupexec=shutdowngroup$group
        			eval ./ups_action.sh "${!groupexec}" >>$logfile$group &
			done
			echo UPS MONITORING TOOL SHUTING DOWN TO PREVENT MORE PROBLEMS. WAITING FOR BLACKOUT. >>$logfile
			exit 0


		fi



	else
		echo "I've got some Unknown UPS Status, Don't know what to do! I'm sounding alarm and killing myself!" >>$logfile
		eval $alarmline
		exit 1

	fi
fi
done
