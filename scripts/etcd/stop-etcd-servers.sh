#!/usr/bin/env bash

#Launch the etcd lxc containers
. ../run-as-root.sh

ETCD_SERVERS=
if [ $# -eq 0 ];
  then
    ETCD_SERVERS="etcd-1 etcd-2 etcd-3"
    echo "No arguments supplied - stopping  $ETCD_SERVERS"
  else
    ETCD_SERVERS=$@
    echo "Stopping  $ETCD_SERVERS"
fi

for instance in $ETCD_SERVERS; do
  lxc exec ${instance} -- systemctl daemon-reload
  lxc exec ${instance} -- systemctl stop etcd
  echo "Stopped ${instance}"
done
