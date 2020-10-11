#!/usr/bin/env bash

#Generate kube-proxy kube config

{ 
  
  GEN_CERTS_PATH=../../certificates/generated
  GEN_CONFIG_PATH=../../kubeconfigs
  mkdir -p ${GEN_CONFIG_PATH}

  KUBERNETES_PUBLIC_ADDRESS=$(lxc list | grep loadbalancer | awk '{print $6}')

  kubectl config set-cluster kubernetes-cluster-ground-up-from-sources \
    --certificate-authority=${GEN_CERTS_PATH}/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${GEN_CONFIG_PATH}/kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=${GEN_CERTS_PATH}/kube-proxy.pem \
    --client-key=${GEN_CERTS_PATH}/kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=${GEN_CONFIG_PATH}/kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-cluster-ground-up-from-sources \
    --user=system:kube-proxy \
    --kubeconfig=${GEN_CONFIG_PATH}/kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=${GEN_CONFIG_PATH}/kube-proxy.kubeconfig
}

