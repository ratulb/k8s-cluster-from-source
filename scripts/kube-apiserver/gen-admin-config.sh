#!/usr/bin/env bash

#Generate admin kube config file


{
  kubectl config set-cluster kubernetes-cluster-ground-up-from-sources \
    --certificate-authority=../certificates/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=../kubeconfigs/admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=../certificates/admin.pem \
    --client-key=../certificates/admin-key.pem \
    --embed-certs=true \
    --kubeconfig=../kubeconfigs/admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-cluster-ground-up-from-sources \
    --user=admin \
    --kubeconfig=../kubeconfigs/admin.kubeconfig

  kubectl config use-context default --kubeconfig=../kubeconfigs/admin.kubeconfig
}
