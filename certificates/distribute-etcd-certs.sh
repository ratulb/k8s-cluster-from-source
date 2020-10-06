#!/usr/bin/env bash

#Distribute the distribute etcd nodes' certificate/keys along with the ca.pem file
#Create required directories if needed

for instance in etcd-1 etcd-2 etcd-3; do
  lxc exec ${instance} -- mkdir -p /etc/etcd
  lxc file push ca.pem ${instance}-key.pem ${instance}.pem ${instance}/etc/etcd/
  COPIED=$?
  if [ $COPIED -ne 0 ]; then
   echo "Error while copying etcd certificates to ${instance}"
  else
    echo "Copied etcd certificates to ${instance}"
  fi
done
