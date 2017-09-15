#!/bin/bash

###############################################################################
# Wrapper for hadoop daemons
###############################################################################

# Hadoop daemons require root
if [ $EUID -ne 0 ]; then
  echo "$0 must be run with root authority"
  exit 1
fi

# Setup config/env
if [ -e ${SNAP}/wrappers/hadoop-common-wrapper.sh ]; then
  . ${SNAP}/wrappers/hadoop-common-wrapper.sh
else
  echo "Could not find 'hadoop-common-wrapper.sh':"
  echo ""
  echo "${SNAP}/wrappers/hadoop-common-wrapper.sh"
  exit 1
fi

# Create daemon (root) writable locations as needed
# HDFS
export HADOOP_LOG_DIR=${SNAP_DATA}/var/log/hadoop-hdfs
export HADOOP_PID_DIR=${SNAP_DATA}/var/run/hadoop-hdfs

# Mapred
export HADOOP_MAPRED_LOG_DIR=${SNAP_DATA}/var/log/hadoop-mapreduce
export HADOOP_MAPRED_PID_DIR=${SNAP_DATA}/var/run/hadoop-mapreduce

# YARN
export HADOOP_YARN_LOG_DIR=${SNAP_DATA}/var/log/hadoop-yarn
export HADOOP_YARN_PID_DIR=${SNAP_DATA}/var/run/hadoop-yarn

# Daemon uses chown and nohup; set path to prefer the bins packed into the snap
export PATH=${SNAP}/bin:${SNAP}/usr/bin:$PATH

# Run the daemon script
exec ${SNAP}/usr/lib/hadoop/sbin/hadoop-daemon.sh "$@"
