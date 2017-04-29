#!/bin/bash

DNS_SCRIPT=/usr/bin/mesos-dns
DNS_CONFIG=/data/workspace/mesos/conf/mesos-dns-config.json
DNS_PID_FILE=/var/run/mesos-dns.pid
DNS_LOGS=/data/workspace/mesos/logs/mesos-dns.log

dns-start(){
	if [ -f $DNS_PID_FILE ];
	then
		echo "The Mesos DNS seems running, please run with [dns-status] to get the pid number, and check it"
	else
		$DNS_SCRIPT -conifg $DNS_CONFIG >> $DNS_LOGS 2>&1 &
		echo $! > $DNS_PID_FILE
		echo "Mesos DNS has been startd."
	fi
}

dns-stop(){
	if [ -f $DNS_PID_FILE ];
	then
		PID=`cat $DNS_PID_FILE`
		echo "Killing the process with pid $PID."
		kill -9 $PID	
		if [ $? -eq 0 ];
		then
			echo "Mesos DNS has been stopped."
			rm -f $DNS_PID_FILE
		else
			echo "Mesos DNS is stopped fail, please check again."
		fi
	else
		echo "Mesos DNS seems not running yet."
	fi
}

dns-restart(){

	dns-stop
	echo "Wait for 5 sec."
	sleep 5
	dns-start
}

dns-status(){
	if [ -f $DNS_PID_FILE ];
	then
		PID=`cat $DNS_PID_FILE`
		echo "The Mesos DNS is running, pid is $PID."
	else
		echo "The Mesos DNS is not running."
	fi
}

case "$1" in
  'dns-start')
	dns-start
	;;
  'dns-stop')
	dns-stop
	;;
  'dns-restart')
	dns-restart
	;;
  'dns-status')
	dns-status
	;;
  *)
	echo "Usage: $0 dns-start|dns-stop|dns-restart|dns-status"
	exit 1
	;;
esac

exit 0
