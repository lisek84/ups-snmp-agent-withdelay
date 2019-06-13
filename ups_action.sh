#!/bin/bash
## This script will immediately send shutdown to machine provided as first parameter and to slaves if they were configured.

if [ "$#" -lt '1' ]; then
	clear
	echo ----------------------------------------------------------------
	echo - Please provide IP addresses required for datacenter shutdown -
	echo -                                                              -
	echo -  $0 - MainIP SlaveIP1 SlaveIP2 SlaveIP3......              -
	echo ----------------------------------------------------------------
	exit 1
fi

# Reading configuration files
cd `dirname $0`
. config.cfg

MainMachineIP="$1"
shift
SlavesIP="$@"


# Showing What I have received:
echo "Running shutdown procedure for Machine with IP: $MainMachineIP"
echo "And after this I will:"

if [ "$waituntildown" -eq 0 ]; then 

                        echo "I'm just sending Shutdown procedure to every machine in group at once NOW!"
                        echo "SENDING SHUTDOWN TO MAIN MACHINE:"
                        ipmilogin=`grep $MainMachineIP credentials.cfg | awk '{print $2}'`
                        ipmipass=`grep $MainMachineIP credentials.cfg | awk '{print $3}'`
                        $ipmitool -H $MainMachineIP -U $ipmilogin -P $ipmipass $ipmicommand
                                echo "SHUTTING DOWN SLAVES NOW!"
                                for slave in $SlavesIP; do
                                        echo Shutting down machine with $slave address.
                                        ipmilogin=`grep $slave credentials.cfg | awk '{print $2}'`
                                        ipmipass=`grep $slave credentials.cfg | awk '{print $3}'`
                                        $ipmitool -H $slave -U $ipmilogin -P $ipmipass $ipmicommand
                                done
                                exit 0



else
			if [ "$killeitherway" -eq 0 ]; then echo "I'll wait and try to ping $MainMachineIP for $wait_until_main_down_for seconds. And after this I'll kill all the slaves: $SlavesIP but only if main server is really down and not responding."
			echo "SENDING SHUTDOWN TO MAIN MACHINE:"
			ipmilogin=`grep $MainMachineIP credentials.cfg | awk '{print $2}'`
			ipmipass=`grep $MainMachineIP credentials.cfg | awk '{print $3}'`
			$ipmitool -H $MainMachineIP -U $ipmilogin -P $ipmipass $ipmicommand
			echo "NOW. I WILL WAIT for $wait_until_main_down_for seconds and send ping to machine. If it will respond I will not do anything about this. If he'll not respond. I will Begin Shutting down Slave Machines"
				sleep $wait_until_main_down_for
				echo WAIT IS OVER. SENDING PING
				result=`ping -c 10 -W 10 -w 10 $MainMachineIP 1>/dev/null 2>&1`;
				code=$?

				if [ $code -eq 0 ]; then echo "SORRY. MAIN MACHINE IS STILL RESPONDING. I AM CONFIGURED TO LEAVE IT AND EXIT, AND THATS WHAT I WILL DO NOW!"; exit 1
				fi

				echo MAIN MACHINE IS DOWN. SHUTTING DOWN SLAVES NOW!
				for slave in $SlavesIP; do
					echo Shutting down machine with $slave address.
 		                        ipmilogin=`grep $slave credentials.cfg | awk '{print $2}'`
                 		        ipmipass=`grep $slave credentials.cfg | awk '{print $3}'`
					$ipmitool -H $slave -U $ipmilogin -P $ipmipass $ipmicommand
				done
				exit 0	

			else
			echo "I'll wait and try to ping $MainMachineIP for $wait_until_main_down_for seconds. And after this I'll kill all the slaves: $SlavesIP even is main server is still running."
                        echo "SENDING SHUTDOWN TO MAIN MACHINE:"
                        ipmilogin=`grep $MainMachineIP credentials.cfg | awk '{print $2}'`
                        ipmipass=`grep $MainMachineIP credentials.cfg | awk '{print $3}'`
                        $ipmitool -H $MainMachineIP -U $ipmilogin -P $ipmipass $ipmicommand
                        echo "NOW. I WILL WAIT for $wait_until_main_down_for. Regardless of anything I will Begin Shutting down Slave Machines, even is Main Machine is still running. It was your choice in my configuration. Don't blame me is something nasty happens"
                                sleep $wait_until_main_down_for
                                echo "SHUTTING DOWN SLAVES NOW!"
                                for slave in $SlavesIP; do
                                        echo Shutting down machine with $slave address.
                                        ipmilogin=`grep $slave credentials.cfg | awk '{print $2}'`
                                        ipmipass=`grep $slave credentials.cfg | awk '{print $3}'`
                                        $ipmitool -H $slave -U $ipmilogin -P $ipmipass $ipmicommand
                                done
                                exit 0


			fi
fi
