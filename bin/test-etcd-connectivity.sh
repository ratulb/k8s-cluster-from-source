#!/usr/bin/env bash

#Test connectivity to the etcd endpoints with kube-apiserver credentials

ETCD1_IP=$(lxc list | grep etcd-1 | awk '{print $6}')
ETCD2_IP=$(lxc list | grep etcd-2 | awk '{print $6}')
ETCD3_IP=$(lxc list | grep etcd-3 | awk '{print $6}')
ENDPOINTS=https://${ETCD1_IP}:2379,https://${ETCD2_IP}:2379,https://${ETCD1_IP}:2379

ETCDCTL_API=3 etcdctl member list --endpoints=${ENDPOINTS} --cacert=../certificates/ca.pem --cert=../certificates/kubernetes.pem --key=../certificates/kubernetes-key.pem

ETCDCTL_API=3 etcdctl --endpoints=${ENDPOINTS} put foo "Hello World!" --cacert=../certificates/ca.pem --cert=../certificates/kubernetes.pem --key=../certificates/kubernetes-key.pem
ETCDCTL_API=3 etcdctl --endpoints=${ENDPOINTS} get foo --cacert=../certificates/ca.pem --cert=../certificates/kubernetes.pem --key=../certificates/kubernetes-key.pem
ETCDCTL_API=3 etcdctl --endpoints=${ENDPOINTS} --write-out="json" get foo --cacert=../certificates/ca.pem --cert=../certificates/kubernetes.pem --key=../certificates/kubernetes-key.pem
