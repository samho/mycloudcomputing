#!/bin/bash

MESOS_MASTER_SCRIPT=/usr/local/sbin/mesos-master
MESOS_AGENT_SCRIPT=/usr/local/sbin/mesos-agent
MASTER_WORK_DIR=/data/workspace/mesos/master/data
AGENT_WORK_DIR=/data/workspace/mesos/agent/data
ZK_MASTER="zk://10.8.56.99:2181,10.8.56.99:2182,10.8.56.99:2183/mesos"
#ZK_MASTER="zk://45.249.245.139:2181,45.249.245.139:2182,45.249.245.139:2183/mesos_pub"
QUORUM=1
MASTER_HOSTNAME="mesos-master"
AGENT_HOSTNAME="mesos-agent-local"
MASTER_LOG_DIR=/data/workspace/mesos/master/logs
AGENT_LOG_DIR=/data/workspace/mesos/agent/logs
MASTER_LOCK=/var/run/mesos-master.lock
MASTER_PID_FILE=/var/run/mesos-master.pid
AGENT_LOCK=/var/run/mesos-agent.lock
AGENT_PID_FILE=/var/run/mesos-agent.pid
AGENT_VM_METHOD="docker"

master-start(){
	if [ -f $MASTER_PID_FILE ];
	then
		echo "The Mesos Master seems running, please run with [master-status] to get the pid number, and check it"
	else
		$MESOS_MASTER_SCRIPT --work_dir=$MASTER_WORK_DIR --zk=$ZK_MASTER --quorum=$QUORUM --hostname=$MASTER_HOSTNAME --log_dir=$MASTER_LOG_DIR >> $MASTER_LOG_DIR/master.log 2>&1 &
		echo $! > $MASTER_PID_FILE
		echo "Mesos master has been startd."
	fi
}

master-stop(){
	if [ -f $MASTER_PID_FILE ];
	then
		PID=`cat $MASTER_PID_FILE`
		echo "Killing the process with pid $PID."
		kill -9 $PID	
		if [ $? -eq 0 ];
		then
			echo "Mesos master has been stopped."
			rm -f $MASTER_PID_FILE
		else
			echo "Mesos master is stopped fail, please check again."
		fi
	else
		echo "Mesos master seems not running yet."
	fi
}

master-restart(){

	master-stop
	echo "Wait for 5 sec."
	sleep 5
	master-start
}

master-status(){
	if [ -f $MASTER_PID_FILE ];
	then
		PID=`cat $MASTER_PID_FILE`
		echo "The Mesos master is running, pid is $PID."
	else
		echo "The Mesos master is not running."
	fi
}

agent-start(){
	if [ -f $AGENT_PID_FILE ];
	then
		echo "The Mesos Agent seems running, please run with [agent-status] to get the pid number, and check it"
	else
		$MESOS_AGENT_SCRIPT --containerizers=$AGENT_VM_METHOD --work_dir=$AGENT_WORK_DIR --master=$ZK_MASTER --hostname=$AGENT_HOSTNAME --log_dir=$AGENT_LOG_DIR >> $AGENT_LOG_DIR/agent.log 2>&1 &
		echo $! > $AGENT_PID_FILE
		echo "Mesos agent has been startd."
	fi
}

agent-stop(){
	if [ -f $AGENT_PID_FILE ];
	then
		PID=`cat $AGENT_PID_FILE`
		echo "Killing the process with pid $PID."
		kill -9 $PID	
		if [ $? -eq 0 ];
		then
			echo "Mesos agent has been stopped."
			rm -f $AGENT_PID_FILE
		else
			echo "Mesos agent is stopped fail, please check again."
		fi
	else
		echo "Mesos agent seems not running yet."
	fi
}

agent-restart(){

	agent-stop
	echo "Wait for 5 sec."
	sleep 5
	agent-start
}

agent-status(){
	if [ -f $AGENT_PID_FILE ];
	then
		PID=`cat $AGENT_PID_FILE`
		echo "The Mesos agent is running, pid is $PID."
	else
		echo "The Mesos agent is not running."
	fi
}

case "$1" in
  'master-start')
	master-start
	;;

  'master-stop')
	master-stop
	;;

  'master-restart')
	master-restart
	;;

  'master-status')
	master-status
	;;
  'agent-start')
	agent-start
	;;
  'agent-stop')
	agent-stop
	;;
  'agent-restart')
	agent-restart
	;;
  'agent-status')
	agent-status
	;;
  *)
	echo "Usage: $0 master-start|master-stop|master-restart|master-status|agent-start|agent-stop|agent-restart|agent-status"
	exit 1
	;;
esac

exit 0
