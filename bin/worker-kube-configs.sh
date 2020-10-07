#!/usr/bin/env bash

#Generate each worker nodes kube config files

{

KUBERNETES_PUBLIC_ADDRESS=$(lxc list | grep loadbalancer | awk '{print $6}')

for instance in worker-1 worker-2 worker-3; do
  kubectl config set-cluster kubernetes-cluster-ground-up-from-sources \
    --certificate-authority=../certificates/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=../certificates/${instance}.pem \
    --client-key=../certificates/${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-cluster-ground-up-from-sources \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done
}
