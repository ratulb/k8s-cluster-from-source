#!/usr/bin/env bash

#Distribute the admin config file and kubectl binary to master nodes
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
  lxc file push ../kubeconfigs/admin.kubeconfig ${instance}/root/
  lxc file push ../kube-binaries/kubectl ${instance}/usr/local/bin/
done
