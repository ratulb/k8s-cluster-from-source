#!/usr/bin/env bash

#Create etcd data dirctories in each etcd host

for instance in etcd-1 etcd-2 etcd-3; do
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

