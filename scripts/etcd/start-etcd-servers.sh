#!/usr/bin/env bash

#Reload daemons and restart service

ETCD_SERVERS=
if [ $# -eq 0 ];
  then
    ETCD_SERVERS="etcd-1 etcd-2 etcd-3"
    echo "No arguments supplied - starting $ETCD_SERVERS"
  else
    ETCD_SERVERS=$@
    echo "Starting $ETCD_SERVERS"
fi

for instance in $ETCD_SERVERS; do
  lxc exec ${instance} -- systemctl daemon-reload
  lxc exec ${instance} -- systemctl stop etcd
  lxc exec ${instance} -- systemctl enable etcd
  lxc exec ${instance} -- systemctl start etcd
done
