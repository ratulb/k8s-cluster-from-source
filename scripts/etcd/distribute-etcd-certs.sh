#!/usr/bin/env bash

#Distribute the distribute etcd nodes' certificate/keys along with the ca.pem file
#Create required directories if needed
ETCD_SERVERS=
if [ $# -eq 0 ];
  then
    ETCD_SERVERS="etcd-1 etcd-2 etcd-3"
    echo "No arguments supplied - copying certs for $ETCD_SERVERS"
  else
    ETCD_SERVERS=$@
    echo "Copying certs for $ETCD_SERVERS"
fi

GENERATED_DIR=../../certificates/generated

for instance in $ETCD_SERVERS; do
  lxc exec ${instance} -- mkdir -p /etc/etcd
  lxc file push ${GENERATED_DIR}/ca.pem ${GENERATED_DIR}/${instance}-key.pem ${GENERATED_DIR}/${instance}.pem ${instance}/etc/etcd/
  COPIED=$?
  if [ $COPIED -ne 0 ]; then
   echo "Error while copying etcd certificates to ${instance}"
  else
    echo "Copied etcd certificates to ${instance}"
  fi
done
