#!/usr/bin/env bash

#Shutdown the cluster

WORKERS="worker-1 worker-2 worker-3"
for instance in $WORKERS; do
  lxc exec ${instance} -- systemctl daemon-reload
  lxc exec ${instance} -- systemctl start kubelet
  lxc exec ${instance} -- systemctl start kube-proxy
done

echo "Workers started..."

MASTERS="master-1 master-2 master-3"
for instance in $MASTERS; do
  lxc exec ${instance} -- systemctl daemon-reload
  lxc exec ${instance} -- systemctl start kube-apiserver
  lxc exec ${instance} -- systemctl start kube-scheduler
  lxc exec ${instance} -- systemctl start kube-controller-manager
done
echo "Masters started..."

ECTD_SERVERS="etcd-1 etcd-2 etcd-3"
for instance in $ETCD_SERVERS; do
  lxc exec ${instance} -- systemctl daemon-reload
  lxc exec ${instance} -- systemctl start etcd
done
echo "Etcd servers started..."

lxc exec loadbalancer -- systemctl daemon-reload
lxc exec loadbalancer -- systemctl start haproxy

echo "Load balancer started.."
