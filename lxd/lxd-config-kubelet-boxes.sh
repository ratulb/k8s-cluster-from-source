#!/usr/bin/env bash

#Reload daemons and restart  kubelet service

. ../scripts/run-as-root.sh

WORKERS=

if [ $# -eq 0 ];
  then
    WORKERS="worker-1 worker-2 worker-3"
    echo "No arguments supplied - lxd configuration for $WORKERS"
  else
    WORKERS=$@
    echo "lxd configuration for $WORKERS"
fi

for instance in $WORKERS; do
  lxc config set ${instance} linux.kernel_modules "ip_tables,ip6_tables,netlink_diag,nf_nat,overlay"
  lxc config set ${instance} raw.lxc "lxc.apparmor.profile=unconfined\nlxc.cap.drop= \nlxc.cgroup.devices.allow=a\nlxc.mount.auto=proc:rw sys:rw"
  lxc config set ${instance} security.privileged "true"
done

echo "lxd configuration done"
