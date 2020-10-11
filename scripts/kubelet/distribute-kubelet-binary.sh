#!/usr/bin/env bash

#Copy the kubelet binary to worker nodes
{
KUBE_BINARIES_DIR=../../kube-binaries
chmod +x ${KUBE_BINARIES_DIR}/kubelet
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
for instance in $WORKERS; do
 lxc file push  ${KUBE_BINARIES_DIR}/kubelet  ${instance}/usr/local/bin/
 COPIED=$?
 if [ $COPIED -ne 0 ]; then
   echo "Error while copying kubelet binary to ${instance}"
 else
    echo "Copied kubelet binary to ${instance}"
 fi
done
}

