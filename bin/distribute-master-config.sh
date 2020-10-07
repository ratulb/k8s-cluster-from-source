#!/usr/bin/env bash

#Distribute the master nodes(control palne)/admin config files to respective nodes
#Create required directories if needed


for instance in master-1 master-2 master-3; do
  lxc file push admin.kubeconfig ${instance}/root/
  lxc exec ${instance} -- mkdir -p /var/lib/kubernetes/
  lxc file push kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${instance}/var/lib/kubernetes/
done
