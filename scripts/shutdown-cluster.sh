#!/usr/bin/env bash

#Shutdown the cluster

WORKERS="worker-1 worker-2 worker-3"
for instance in $WORKERS; do
  lxc exec ${instance} -- systemctl daemon-reload
  lxc exec ${instance} -- systemctl stop kubelet
  lxc exec ${instance} -- systemctl stop kube-proxy
done

echo "Workers shut down..."

MASTERS="master-1 master-2 master-3"
for instance in $MASTERS; do
  lxc exec ${instance} -- systemctl daemon-reload
  lxc exec ${instance} -- systemctl stop kube-apiserver
  lxc exec ${instance} -- systemctl stop kube-scheduler
  lxc exec ${instance} -- systemctl stop kube-controller-manager
done
echo "Masters shut down..."

ECTD_SERVERS="etcd-1 etcd-2 etcd-3"
for instance in $ETCD_SERVERS; do
  lxc exec ${instance} -- systemctl daemon-reload
  lxc exec ${instance} -- systemctl stop etcd
done
echo "Etcd servers shut down..."

lxc exec loadbalancer -- systemctl daemon-reload
lxc exec loadbalancer -- systemctl stop haproxy

echo "Load balancer shut down..."
