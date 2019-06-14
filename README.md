# UPS SNMP Shutdown Agent with Slave machines support

This tool will monitor your UPS over snmp.

And if powerdown will be detected. It will shutdown your computers
.
For this it uses IPMI, but you can change it and define your own methods (ssh, psexec etc)
It is different from other tools because it's prepared for storage boxes.

So If you have group of servers - First machine is Master/Host (For example for RAID Storage) and else is just disk chassis, this tool will shutdown server.
Check is it really down. And if it will be down it will shutdown disk arrays after this.

It's very flexible, and You can change many parameters in it's config.cfg file. 

Configuration is very straightforward - just look for comments in config file.

### Prerequisites
Here I've used IPMITool and snmpwalk
You need them. 
Install is easy. For Debian/Ubuntu just run apt-get install ipmitool snmp

### Installation procedure.
Copy files somewhere you want.
Make sure files ups_action.sh, ups_monitor.sh and upsshutdownagent are executable.
Edit upsshutdownagent and edit path to ups_monitor.sh script.
Copy upsshutdownagent to some init directory (/etc/init, or /etc/init.d) if you are still using upstart. If not - change execution method for your own.
(/bin/systemctl daemon-reload will initiate it)

To enable it at boot time
systemctl enable upsshutdownagent

Installation is over.

### Configuration
Now You need to configure everything in config.cfg.
Also for all your hosts to shutdown, You need to prepare credentials.cfg file.
(If You use same login and password for all of them - use build_credentials.sh script)
Configuration is described in config.cfg file.

Hope it will help in your job.

### How to run
Run:
service upsshutdownagent (start|stop|restart|status)

## Authors
* **Lisek** (https://github.com/lisek84)

## License

This project is licensed under the GNU License
