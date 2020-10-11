#!/usr/bin/env bash

#Reload daemons and restart  kube scheduler service

for instance in master-1 master-2 master-3; do
  lxc exec ${instance} -- systemctl daemon-reload
  lxc exec ${instance} -- systemctl stop kube-scheduler
  lxc exec ${instance} -- systemctl enable kube-scheduler
  lxc exec ${instance} -- systemctl start kube-scheduler
done
