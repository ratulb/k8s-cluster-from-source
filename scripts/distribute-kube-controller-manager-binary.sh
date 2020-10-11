#!/usr/bin/env bash

#Generate the kube-apiserver system file for each master node and copy it to the node
{
cd ../kube-binaries/
chmod +x kube-controller-manager

for instance in master-1 master-2 master-3; do
 lxc file push kube-controller-manager  ${instance}/usr/local/bin/
 COPIED=$?
 if [ $COPIED -ne 0 ]; then
   echo "Error while copying kube-controller-manager to ${instance}"
 else
    echo "Copied kube-controller to ${instance}"
 fi
done

cd -

}

