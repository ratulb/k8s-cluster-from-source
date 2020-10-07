#!/usr/bin/env bash

#Copy the kube-scheduler binary to master nodes
{
cd ../kube-binaries/
chmod +x kube-scheduler

for instance in master-1 master-2 master-3; do
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

