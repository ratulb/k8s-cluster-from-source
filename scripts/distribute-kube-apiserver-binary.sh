#!/usr/bin/env bash

#Generate the kube-apiserver system file for each master node and copy it to the node
{
cd ../kube-binaries/
chmod +x kube-apiserver

for instance in master-1 master-2 master-3; do
 lxc exec ${instance} -- systemctl daemon-reload
 lxc exec ${instance} -- systemctl stop kube-apiserver
 lxc file push kube-apiserver  ${instance}/usr/local/bin/
 COPIED=$?
 if [ $COPIED -ne 0 ]; then
   echo "Error while copying kube-apiserver to ${instance}"
 else
    echo "Copied kube-apiserver to ${instance}"
 fi
done

cd -

}

