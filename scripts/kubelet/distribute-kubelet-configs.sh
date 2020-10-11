#!/usr/bin/env bash

#Distribute the worker/kubelet config files to respective worker node
#Create required directories if needed

GEN_CONFIG_PATH=../../kubeconfigs

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
  lxc exec ${instance} -- mkdir -p /var/lib/kubelet/
  lxc file push ${GEN_CONFIG_PATH}/${instance}.kubeconfig ${instance}/var/lib/kubelet/
  lxc exec ${instance} -- mv /var/lib/kubelet/${instance}.kubeconfig /var/lib/kubelet/kubeconfig
  echo "Copied ${instance}.kubeconfig to ${instance}"
done
