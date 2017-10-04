#!/bin/bash

###############################################################################
# Wrapper for all hadoop-related binaries and daemons
###############################################################################

# We have different prefixes if we're calling a hadoop bin from the hadoop
# snap vs a snap that's plugged into hadoop (e.g. pig).
# NB: all snaps that plug into hadoop are expected to have $SNAP/hadoop and
# $SNAP/etc/hadoop dirs that will be automatically mounted when connected.
if [ -x ${SNAP}/usr/lib/hadoop/bin/hadoop ]; then
  # Hadoop snap
  export HADOOP_SNAP_HOME=${SNAP}
elif [ -x ${SNAP}/hadoop/usr/lib/hadoop/bin/hadoop ]; then
  # Plugged snap
  export HADOOP_SNAP_HOME=${SNAP}/hadoop
else
  echo "ERROR: Could not find 'hadoop'"
  exit 1
fi

# Warn if we cant find our hadoop configuration
export HADOOP_CONF_PREFIX=${SNAP_DATA}
if [ ! -e ${HADOOP_CONF_PREFIX}/etc/hadoop/conf ]; then
  echo "WARN: Expected Hadoop configuration not found:"
  echo "${HADOOP_CONF_PREFIX}/etc/hadoop/conf"
fi

# Set hadoop runtime envars
export HADOOP_CONF_DIR=${HADOOP_CONF_PREFIX}/etc/hadoop/conf
export HADOOP_LIBEXEC_DIR=${HADOOP_SNAP_HOME}/usr/lib/hadoop/libexec/
export HADOOP_COMMON_HOME=${HADOOP_SNAP_HOME}/usr/lib/hadoop
export HADOOP_HDFS_HOME=${HADOOP_SNAP_HOME}/usr/lib/hadoop-hdfs
export HADOOP_MAPRED_HOME=${HADOOP_SNAP_HOME}/usr/lib/hadoop-mapreduce
export HADOOP_YARN_HOME=${HADOOP_SNAP_HOME}/usr/lib/hadoop-yarn
export HTTPFS_CONFIG=${HADOOP_CONF_PREFIX}/etc/hadoop-httpfs/conf
export YARN_COMMON_HOME=${HADOOP_SNAP_HOME}/usr/lib/hadoop-yarn
export YARN_CONF_DIR=${HADOOP_CONF_PREFIX}/etc/hadoop/conf

# Set Bigtop envars for java and jsvc
. ${SNAP}/usr/lib/bigtop-utils/bigtop-detect-javahome
export JSVC_HOME=${SNAP}/usr/lib/bigtop-utils
