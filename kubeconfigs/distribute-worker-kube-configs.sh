#!/usr/bin/env bash

#Distribute the worker/kubelet config files to respective worker node
#Create required directories if needed
#Note: kube proxy configs are also being copied to the woker nodes

for instance in worker-1 worker-2 worker-3; do
  lxc exec ${instance} -- mkdir -p /var/lib/kubelet/
  lxc file push ${instance}.kubeconfig kube-proxy.kubeconfig ${instance}/var/lib/kubelet/
  lxc exec ${instance} -- mv /var/lib/kubelet/${instance}.kubeconfig /var/lib/kubelet/kubeconfig
done
