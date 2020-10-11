#!/usr/bin/env bash
#Create the required directories for the kubelet
. ../run-as-root.sh
WORKERS=
if [ $# -eq 0 ];
  then
    WORKERS="worker-1 worker-2 worker-3"
  else
    WORKERS=$@
fi
echo "Setting up for $WORKERS"
GENERATED_DIR=./generated/etc/tmpfiles.d
mkdir -p ${GENERATED_DIR}

cat <<EOF | tee ${GENERATED_DIR}/kmsg.conf
L /dev/kmsg - - - - /dev/console
EOF

for instance in $WORKERS; do
 lxc exec ${instance} -- mkdir -p /etc/cni/net.d /opt/cni/bin /var/lib/kubelet /var/lib/kube-proxy /var/lib/kubernetes /var/run/kubernetes
#https://github.com/corneliusweig/kubernetes-lxd#using-docker-and-kubernetes-on-zfs-backed-host-systems
 lxc file push ${GENERATED_DIR}/kmsg.conf ${instance}/etc/tmpfiles.d/ 
#lxc exec ${instance} -- echo 'L /dev/kmsg - - - - /dev/console' > /etc/tmpfiles.d/kmsg.conf
 echo "Created kubelet directories in ${instance}"
done
