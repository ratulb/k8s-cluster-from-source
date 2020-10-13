#!/usr/bin/env bash

#Create etcd data dirctories in each etcd host
ETCD_SERVERS=
if [ $# -eq 0 ];
  then
    ETCD_SERVERS="etcd-1 etcd-2 etcd-3"
    echo "No arguments supplied - copying certs for $ETCD_SERVERS"
  else
    ETCD_SERVERS=$@
    echo "Copying certs for $ETCD_SERVERS"
fi

for instance in $ETCD_SERVERS; do
  lxc exec ${instance} -- rm -rf /var/lib/etcd
  lxc exec ${instance} -- mkdir -p /var/lib/etcd
  CREATED=$?
  lxc exec ${instance} -- chmod 700 /var/lib/etcd
  MODIFIED=$?
  if [ $CREATED -ne 0 -o $MODIFIED -ne 0 ]; then
   echo "Error while initializing etcd data directory in ${instance}"
  else
   echo "Initialized etcd data directory in ${instance}"
  fi
done

