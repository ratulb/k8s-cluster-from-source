#!/usr/bin/env bash

#Distribute the worker/kubelet certificate/keys along with the ca.pem file
#Create required directories if needed

for instance in worker-1 worker-2 worker-3; do
  lxc exec ${instance} -- mkdir -p /var/lib/kubelet/
  lxc file push ${instance}-key.pem ${instance}.pem ${instance}/var/lib/kubelet/
  lxc exec ${instance} -- mkdir -p /var/lib/kubernetes/
  lxc file push ca.pem ${instance}/var/lib/kubernetes/
done
