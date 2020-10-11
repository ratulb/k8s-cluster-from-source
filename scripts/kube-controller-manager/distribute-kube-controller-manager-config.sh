#!/usr/bin/env bash

#Distribute the kube-controller-manager config files to master nodes
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
  lxc exec ${instance} -- mkdir -p /var/lib/kubernetes/
  lxc file push ../kubeconfigs/kube-controller-manager.kubeconfig ${instance}/var/lib/kubernetes/
done
