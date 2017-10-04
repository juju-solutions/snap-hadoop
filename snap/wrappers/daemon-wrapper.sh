#!/bin/bash

###############################################################################
# Wrapper for hadoop/mapred/yarn daemons
###############################################################################

# Verify args
if [ $# -lt 2 ]; then
  echo "ERROR: Missing required arguments:"
  echo "$0 <start|stop> <hadoop|mapred|yarn-command> <args...>"
  exit 1
else
  STARTSTOP=$1
  shift
  COMMAND=$1
  shift
fi

# All Hadoop daemons require root
if [ $EUID -ne 0 ]; then
  echo "ERROR: $0 must be run with root authority"
  exit 1
fi

# Setup config/env
if [ -e ${SNAP}/wrappers/common-wrapper.sh ]; then
  . ${SNAP}/wrappers/common-wrapper.sh
else
  echo "ERROR: Could not find 'common-wrapper.sh':"
  echo "${SNAP}/wrappers/common-wrapper.sh"
  exit 1
fi

# Export daemon (root) writable locations
# HDFS
export HADOOP_LOG_DIR=${SNAP_DATA}/var/log/hadoop-hdfs
export HADOOP_PID_DIR=${SNAP_COMMON}/var/run/hadoop-hdfs

# Mapred
export HADOOP_MAPRED_LOG_DIR=${SNAP_DATA}/var/log/hadoop-mapreduce
export HADOOP_MAPRED_PID_DIR=${SNAP_COMMON}/var/run/hadoop-mapreduce

# YARN
export YARN_LOG_DIR=${SNAP_DATA}/var/log/hadoop-yarn
export YARN_PID_DIR=${SNAP_COMMON}/var/run/hadoop-yarn

# Daemon uses chown and nohup; set path to prefer the bins packed into the snap
export PATH=${SNAP}/bin:${SNAP}/usr/bin:$PATH

# All hadoop daemons require config; check for that.
if [ ! -e ${HADOOP_CONF_DIR} ]; then
  echo "WARN: Expected Hadoop configuration not found:"
  echo "${HADOOP_CONF_DIR}"
  echo "Daemon cannot be started until config is present."
  exit 0
else
  # Run the daemon script
  case $COMMAND in
    namenode|secondarynamenode|datanode|journalnode)
      exec ${HADOOP_COMMON_HOME}/sbin/hadoop-daemon.sh \
        --config ${HADOOP_CONF_DIR} ${STARTSTOP} ${COMMAND} "$@"
      ;;
    historyserver)
      exec ${HADOOP_MAPRED_HOME}/sbin/mr-jobhistory-daemon.sh \
        --config ${HADOOP_CONF_DIR} ${STARTSTOP} ${COMMAND} "$@"
      ;;
    resourcemanager|nodemanager)
      exec ${HADOOP_YARN_HOME}/sbin/yarn-daemon.sh \
        --config ${HADOOP_CONF_DIR} ${STARTSTOP} ${COMMAND} "$@"
      ;;
    *)
      echo "ERROR: $COMMAND is not recognized"
      exit 1
  esac
fi
