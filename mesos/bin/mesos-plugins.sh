#!/bin/bash

MRRATHON_STARTUP_SCRIPT=/data/env/mesos/plugins/marathon/bin/start
MRRATHON_MASTER="zk://10.8.56.99:2181,10.8.56.99:2182,10.8.56.99:2183/mesos"
MARATHON_ZK="zk://10.8.56.99:2181,10.8.56.99:2182,10.8.56.99:2183/marathon"
MARATHON_WEB_UI="http://45.249.245.139:8080"
MARATHON_PID_FILE=/var/run/marathon.pid
MARATHON_DIR=/data/workspace/mesos/plugins/marathon/
MARATHON_LOGS=$MARATHON_DIR/logs

marathon-start(){
	if [ -f $MARATHON_PID_FILE ];
	then
		echo "The Mesos plugins [Marathon] seems running, please run with [marathon-status] to get the pid number, and check it"
	else
		$MRRATHON_STARTUP_SCRIPT  --master=$MRRATHON_MASTER --zk=$MARATHON_ZK --webui_url=$MARATHON_WEB_UI >> $MARATHON_LOGS/marathon.log 2>&1 &
		echo $! > $MARATHON_PID_FILE
		echo "Mesos plugins [Marathon] has been startd."
	fi
}

marathon-stop(){
	if [ -f $MARATHON_PID_FILE ];
	then
		PID=`cat $MARATHON_PID_FILE`
		echo "Killing the process with pid $PID."
		kill -9 $PID	
		if [ $? -eq 0 ];
		then
			echo "Mesos plugins [Marathon] has been stopped."
			rm -f $MARATHON_PID_FILE
		else
			echo "Mesos plugins [Marathon] is stopped fail, please check again."
		fi
	else
		echo "Mesos plugins [Marathon] seems not running yet."
	fi
}

marathon-restart(){

	marathon-stop
	echo "Wait for 5 sec."
	sleep 5
	marathon-start
}

marathon-status(){
	if [ -f $MARATHON_PID_FILE ];
	then
		PID=`cat $MARATHON_PID_FILE`
		echo "The Mesos plugins [Marathon] is running, pid is $PID."
	else
		echo "The Mesos plugins [Marathon] is not running."
	fi
}

case "$1" in
  'marathon-start')
	marathon-start
	;;
  'marathon-stop')
	marathon-stop
	;;
  'marathon-restart')
	marathon-restart
	;;
  'marathon-status')
	marathon-status
	;;
  *)
	echo "Usage: $0 marathon-start|marathon-stop|marathon-restart|marathon-status"
	exit 1
	;;
esac

exit 0
