#!/usr/bin/env bash

#Distribute the kube-scheduler config files to master nodes
#Create required directories if needed


for instance in master-1 master-2 master-3; do
  lxc exec ${instance} -- mkdir -p /var/lib/kubernetes/
  lxc file push ../kubeconfigs/kube-scheduler.kubeconfig ${instance}/var/lib/kubernetes/
  echo "Copied the kube-scheuler.kubeconfig to ${instance}"
done
