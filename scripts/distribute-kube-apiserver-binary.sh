#!/usr/bin/env bash

#Generate the kube-apiserver system file for each master node and copy it to the node
{
cd ../kube-binaries/
chmod +x kube-apiserver
MASTERS=
if [ $# -eq 0 ];
  then
    MASTERS="master-1 master-2 master-3"
  else
    MASTERS=$@
fi
echo "Setting up $MASTERS"
for instance in $MASTERS; do
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

