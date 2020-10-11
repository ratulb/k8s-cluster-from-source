#!/usr/bin/env bash

#Generate the kube-apiserver system file for each master node and copy it to the node
{
cd ../kube-binaries/
chmod +x kube-controller-manager
MASTERS=
if [ $# -eq 0 ];
  then
    MASTERS="master-1 master-2 master-3"
  else
    MASTERS=$@
fi
echo "Setting up $MASTERS"
for instance in $MASTERS; do lxc file push kube-controller-manager  ${instance}/usr/local/bin/
 COPIED=$?
 if [ $COPIED -ne 0 ]; then
   echo "Error while copying kube-controller-manager to ${instance}"
 else
    echo "Copied kube-controller to ${instance}"
 fi
done
cd -
}

