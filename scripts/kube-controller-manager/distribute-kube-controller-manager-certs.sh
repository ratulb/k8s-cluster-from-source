#!/usr/bin/env bash

#Distribute the kube-controller-manager creds to  master nodes
#Create required directories if needed
#Note: Service account cert and keys are also getting copied via this script
cd ../certificates/
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
  lxc file push ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
  service-account-key.pem ${instance}/var/lib/kubernetes/
done
cd -
