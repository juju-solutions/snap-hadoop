#!/bin/bash

###############################################################################
# Wrapper for mapred daemons
###############################################################################

# MapReduce daemons require root
if [ $EUID -ne 0 ]; then
  echo "ERROR: $0 must be run with root authority"
  exit 1
fi

# Setup config/env
if [ -e ${SNAP}/wrappers/hadoop-common-wrapper.sh ]; then
  . ${SNAP}/wrappers/hadoop-common-wrapper.sh
else
  echo "ERROR: Could not find 'hadoop-common-wrapper.sh':"
  echo ""
  echo "${SNAP}/wrappers/hadoop-common-wrapper.sh"
  exit 1
fi

# Export daemon (root) writable locations
# Mapred
export HADOOP_MAPRED_LOG_DIR=${SNAP_DATA}/var/log/hadoop-mapreduce
export HADOOP_MAPRED_PID_DIR=${SNAP_DATA}/var/run/hadoop-mapreduce

# Daemon uses chown and nohup; set path to prefer the bins packed into the snap
export PATH=${SNAP}/bin:${SNAP}/usr/bin:$PATH

# All hadoop daemons require config; check for that.
if [ ! -e ${HADOOP_CONF_DIR} ]; then
  echo "WARN: Expected Hadoop configuration not found:"
  echo ""
  echo "${HADOOP_CONF_DIR}"
  echo ""
  echo "Daemon cannot be started until config is present."
  exit 0
else
  # Run the daemon script
  exec ${HADOOP_MAPRED_HOME}/sbin/mr-jobhistory-daemon.sh "$@"
fi
