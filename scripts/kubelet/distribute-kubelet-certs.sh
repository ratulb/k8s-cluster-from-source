#!/usr/bin/env bash

#Distribute the worker/kubelet certificate/keys along with the ca.pem file
#Create required directories if needed

GEN_CERTS_PATH=../../certificates/generated

. ../run-as-root.sh
WORKERS=
if [ $# -eq 0 ];
  then
    WORKERS="worker-1 worker-2 worker-3"
    echo "No arguments supplied - copying certs for $WORKERS"
  else
    WORKERS=$@
    echo "Copying certs for $WORKERS"
fi

for instance in $WORKERS; do
  lxc exec ${instance} -- mkdir -p /var/lib/kubelet/
  lxc file push ${GEN_CERTS_PATH}/${instance}-key.pem  ${GEN_CERTS_PATH}/${instance}.pem ${instance}/var/lib/kubelet/
  lxc exec ${instance} -- mkdir -p /var/lib/kubernetes/
  lxc file push ${GEN_CERTS_PATH}/ca.pem ${instance}/var/lib/kubernetes/
done
