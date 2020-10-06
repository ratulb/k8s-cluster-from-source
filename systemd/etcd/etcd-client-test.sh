#!/usr/bin/env bash

#etcdctl along with kubernetes certs are supposed be present in the path which running this script

ETCD1_IP=$(lxc list | grep etcd-1 | awk '{print $6}')
ETCD2_IP=$(lxc list | grep etcd-2 | awk '{print $6}')
ETCD3_IP=$(lxc list | grep etcd-3 | awk '{print $6}')
ENDPOINTS=https://${ETCD1_IP}:2379,https://${ETCD2_IP}:2379,https://${ETCD1_IP}:2379

ETCDCTL_API=3 etcdctl member list --endpoints=${ENDPOINTS} --cacert=ca.pem --cert=kubernetes.pem --key=kubernetes-key.pem

ETCDCTL_API=3 etcdctl --endpoints=${ENDPOINTS} put foo "Hello World!" --cacert=ca.pem --cert=kubernetes.pem --key=kubernetes-key.pem
ETCDCTL_API=3 etcdctl --endpoints=${ENDPOINTS} get foo --cacert=ca.pem --cert=kubernetes.pem --key=kubernetes-key.pem
ETCDCTL_API=3 etcdctl --endpoints=${ENDPOINTS} --write-out="json" get foo --cacert=ca.pem --cert=kubernetes.pem --key=kubernetes-key.pem
