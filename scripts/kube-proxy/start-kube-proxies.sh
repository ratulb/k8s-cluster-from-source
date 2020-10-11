#!/usr/bin/env bash
#Reload daemons and restart  kube-proxy service on worker nodes
. ../run-as-root.sh
WORKERS=
if [ $# -eq 0 ];
  then
    WORKERS="worker-1 worker-2 worker-3"
  else
    WORKERS=$@
fi
echo "Setting up for $WORKERS"

for instance in $WORKERS; do
  lxc exec ${instance} -- systemctl daemon-reload
  lxc exec ${instance} -- systemctl stop kube-proxy
  lxc exec ${instance} -- systemctl enable kube-proxy
  lxc exec ${instance} -- systemctl start kube-proxy
done
