#!/usr/bin/env bash

#Copy the kube-scheduler binary to master nodes
{
cd ../kube-binaries/
chmod +x kube-scheduler
MASTERS=
if [ $# -eq 0 ];
  then
    MASTERS="master-1 master-2 master-3"
  else
    MASTERS=$@
fi
echo "Setting up $MASTERS"
for instance in $MASTERS; do
 lxc file push kube-scheduler  ${instance}/usr/local/bin/
 COPIED=$?
 if [ $COPIED -ne 0 ]; then
   echo "Error while copying kube-scheduler binary to ${instance}"
 else
    echo "Copied kube-scheduler binary to ${instance}"
 fi
done
cd -
}

