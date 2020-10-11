#!/usr/bin/env bash
#Reload daemons and restart  kubelet service
. ../run-as-root.sh
WORKERS=
if [ $# -eq 0 ];
  then
    WORKERS="worker-1 worker-2 worker-3"
    echo "No arguments supplied - setting up for $WORKERS"
  else
    WORKERS=$@
    echo "Setting up for $WORKERS"
fi
for instance in $WORKERS; do
  lxc exec ${instance} reboot
done
