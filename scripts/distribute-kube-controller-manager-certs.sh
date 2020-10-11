#!/usr/bin/env bash

#Distribute the kube-controller-manager creds to  master nodes
#Create required directories if needed
#Note: Service account cert and keys are also getting copied via this script
cd ../certificates/
for instance in master-1 master-2 master-3; do
  lxc exec ${instance} -- mkdir -p /var/lib/kubernetes/
  lxc file push ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
  service-account-key.pem ${instance}/var/lib/kubernetes/
done

cd -
