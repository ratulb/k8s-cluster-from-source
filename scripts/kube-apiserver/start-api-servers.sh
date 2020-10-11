#!/usr/bin/env bash

#Reload daemons and restart service

for instance in master-1 master-2 master-3; do
  lxc exec ${instance} -- systemctl daemon-reload
  lxc exec ${instance} -- systemctl stop kube-apiserver
  lxc exec ${instance} -- systemctl enable kube-apiserver
  lxc exec ${instance} -- systemctl start kube-apiserver
done
