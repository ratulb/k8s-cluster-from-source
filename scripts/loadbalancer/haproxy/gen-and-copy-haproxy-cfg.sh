#!/usr/bin/env bash

#Generate the etcd system file for haproxy load balancer and copy it the box

GENERATED_DIR=generated

mkdir -p ${GENERATED_DIR}

LOADBALANCER_IP=$(lxc list | grep loadbalancer | awk '{print $6}')

MASTER1_IP=$(lxc list | grep master-1 | awk '{print $6}')
MASTER2_IP=$(lxc list | grep master-2 | awk '{print $6}')
MASTER3_IP=$(lxc list | grep master-3 | awk '{print $6}')

cat <<EOF | tee ${GENERATED_DIR}/haproxy.cfg

global
    maxconn 20000
    log /dev/log local0

defaults
    timeout connect 10s
    timeout client 30s
    timeout server 30s

frontend kube-apiservers
    bind ${LOADBALANCER_IP}:6443
    option tcplog
    mode tcp
    default_backend kube-apiserver-nodes

backend kube-apiserver-nodes
    mode tcp
    balance roundrobin
    option tcp-check
    server master-1 ${MASTER1_IP}:6443 check fall 3 rise 2
    server master-2 ${MASTER2_IP}:6443 check fall 3 rise 2
    server master-3 ${MASTER3_IP}:6443 check fall 3 rise 2
EOF

lxc file push ${GENERATED_DIR}/haproxy.cfg loadbalancer/etc/haproxy/
