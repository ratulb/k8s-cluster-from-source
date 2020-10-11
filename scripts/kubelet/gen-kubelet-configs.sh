#!/usr/bin/env bash

#Generate each worker nodes kube config files

{
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

#The load balancer IP fronting the kube-apiservers
KUBERNETES_PUBLIC_ADDRESS=$(lxc list | grep loadbalancer | awk '{print $6}')

GEN_CERTS_PATH=../../certificates/generated
GEN_CONFIG_PATH=../../kubeconfigs
mkdir -p ${GEN_CONFIG_PATH}
for instance in $WORKERS; do
  kubectl config set-cluster kubernetes-cluster-ground-up-from-sources \
    --certificate-authority=${GEN_CERTS_PATH}/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${GEN_CONFIG_PATH}/${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=${GEN_CERTS_PATH}/${instance}.pem \
    --client-key=${GEN_CERTS_PATH}/${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${GEN_CONFIG_PATH}/${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-cluster-ground-up-from-sources \
    --user=system:node:${instance} \
    --kubeconfig=${GEN_CONFIG_PATH}/${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${GEN_CONFIG_PATH}/${instance}.kubeconfig
done
}
