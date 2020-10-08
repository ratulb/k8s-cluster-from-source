#!/usr/bin/env bash

#Get latest etcd binaries,  copy them to /usr/bin/local @etcd nodes etcd-1, etcd-2 & etcd-3

{
ETCD_VER=v3.4.13
ETCD_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${ETCD_URL}

mkdir -p ../etcd/etcd-download/

wget -q --show-progress --https-only --timestamping ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -P ../etcd/
tar xzf ../etcd/etcd-${ETCD_VER}-linux-amd64.tar.gz -C ../etcd/etcd-download/ --strip-components=1 

for instance in etcd-1 etcd-2 etcd-3; do
 lxc exec ${instance} -- systemctl daemon-reload
 lxc exec ${instance} -- systemctl stop etcd
 lxc file push ../etcd/etcd-download/etcd ../etcd/etcd-download/etcdctl ${instance}/usr/local/bin/
 COPIED=$?
 if [ $COPIED -ne 0 ]; then
   echo "Error while copying etcd binaries to ${instance}"
 else
    echo "Copied etcd binaries to ${instance}"
 fi
done

}

