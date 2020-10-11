#!/usr/bin/env bash

#Generate kube-controller-manager kube config


{
  kubectl config set-cluster kubernetes-cluster-ground-up-from-sources \
    --certificate-authority=../certificates/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=../kubeconfigs/kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=../certificates/kube-controller-manager.pem \
    --client-key=../certificates/kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=../kubeconfigs/kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-cluster-ground-up-from-sources \
    --user=system:kube-controller-manager \
    --kubeconfig=../kubeconfigs/kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=../kubeconfigs/kube-controller-manager.kubeconfig
}

