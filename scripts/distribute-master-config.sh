#!/usr/bin/env bash

#Distribute the master nodes(control palne)/admin config files to respective nodes
#Create required directories if needed


MASTERS=
if [ $# -eq 0 ];
  then
    MASTERS="master-1 master-2 master-3"
  else
    MASTERS=$@
fi
echo "Setting up $MASTERS"
for instance in $MASTERS; do
  lxc file push admin.kubeconfig ${instance}/root/
  lxc exec ${instance} -- mkdir -p /var/lib/kubernetes/
  lxc file push kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${instance}/var/lib/kubernetes/
done
