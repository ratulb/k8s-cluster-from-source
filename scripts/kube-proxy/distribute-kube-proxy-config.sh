#!/usr/bin/env bash

#Distribute the kube-proxy config files to respective worker node
#Create required directories if needed

GEN_CONFIG_PATH=../../kubeconfigs

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
  lxc exec ${instance} -- mkdir -p /var/lib/kube-proxy
  lxc file push ${GEN_CONFIG_PATH}/kube-proxy.kubeconfig ${instance}/var/lib/kube-proxy/kubeconfig
  echo "Copied kube-proxy.kubeconfig to ${instance}"
done
