#!/usr/bin/env bash

#Generate kube-scheduler kube config

{
  kubectl config set-cluster kubernetes-cluster-ground-up-from-sources \
    --certificate-authority=../certificates/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=../kubeconfigs/kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=../certificates/kube-scheduler.pem \
    --client-key=../certificates/kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=../kubeconfigs/kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-cluster-ground-up-from-sources \
    --user=system:kube-scheduler \
    --kubeconfig=../kubeconfigs/kube-scheduler.kubeconfig

  kubectl config use-context default --kubeconfig=../kubeconfigs/kube-scheduler.kubeconfig
}

