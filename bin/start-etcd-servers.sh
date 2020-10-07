#!/usr/bin/env bash

#Reload daemons and restart service

for instance in etcd-1 etcd-2 etcd-3; do
  lxc exec ${instance} -- systemctl daemon-reload
  lxc exec ${instance} -- systemctl stop etcd
  lxc exec ${instance} -- systemctl enable etcd
  lxc exec ${instance} -- systemctl start etcd
done
