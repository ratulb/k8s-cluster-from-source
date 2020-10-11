#!/usr/bin/env bash

#Distribute the kube-controller-manager config files to master nodes
#Create required directories if needed


for instance in master-1 master-2 master-3; do
  lxc exec ${instance} -- mkdir -p /var/lib/kubernetes/
  lxc file push ../kubeconfigs/kube-controller-manager.kubeconfig ${instance}/var/lib/kubernetes/
done
