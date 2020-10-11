#!/usr/bin/env bash

#Generate kube-proxy kube config

{
  KUBERNETES_PUBLIC_ADDRESS=$(lxc list | grep loadbalancer | awk '{print $6}')

  kubectl config set-cluster kubernetes-cluster-ground-up-from-sources \
    --certificate-authority=../certificates/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=../certificates/kube-proxy.pem \
    --client-key=../certificates/kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-cluster-ground-up-from-sources \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
}

