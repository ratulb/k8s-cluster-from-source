#!/usr/bin/env bash
. ../run-as-root.sh

WORKERS=

if [ $# -eq 0 ];
  then
    WORKERS="worker-1 worker-2 worker-3"
    echo "No arguments supplied - setting up for $WORKERS"
  else
    WORKERS=$@
    echo "Setting up for $WORKERS"
fi


VERSION=1.3.4
for instance in $WORKERS; do
  lxc exec ${instance} -- wget -q --show-progress --https-only --timestamping https://storage.googleapis.com/cri-containerd-release/cri-containerd-cni-${VERSION}.linux-amd64.tar.gz
done
printf "\nDone downloading cri-containerd-cni\n"
for instance in $WORKERS; do
  lxc exec ${instance} -- tar --no-overwrite-dir -C / -xzf cri-containerd-cni-${VERSION}.linux-amd64.tar.gz
done
printf "\nDone installing  cri-containerd-cni\n"

#https://github.com/docker/for-linux/issues/475
for instance in $WORKERS; do
 lxc exec ${instance} -- sed -i 's/ExecStartPre=\/sbin\/modprobe\ overlay/#ExecStartPre=\/sbin\/modprobe\ overlay/' /etc/systemd/system/containerd.service
done
for instance in $WORKERS; do

  lxc exec ${instance} -- systemctl daemon-reload
  lxc exec ${instance} -- systemctl stop containerd
  lxc exec ${instance} -- systemctl enable containerd
  lxc exec ${instance} -- systemctl start containerd
   echo "Restarted containerd"
done 

printf "\nInstalled cri-containerd-cni\n"
