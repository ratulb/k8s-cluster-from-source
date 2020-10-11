#!/usr/bin/env bash

#Copy the kube-proxy binary to worker nodes
{
KUBE_BINARIES_DIR=../../kube-binaries
chmod +x ${KUBE_BINARIES_DIR}/kube-proxy
. ../run-as-root.sh

WORKERS=
if [ $# -eq 0 ];
  then
    WORKERS="worker-1 worker-2 worker-3"
  else
    WORKERS=$@
fi
echo "Setting up for $WORKERS"

for instance in $WORKERS; do
 lxc file push  ${KUBE_BINARIES_DIR}/kube-proxy  ${instance}/usr/local/bin/
 COPIED=$?
 if [ $COPIED -ne 0 ]; then
   echo "Error while copying kube-proxy binary to ${instance}"
 else
    echo "Copied kube-proxy binary to ${instance}"
 fi
done
}

