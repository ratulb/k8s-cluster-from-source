#!/usr/bin/env bash

#Get latest etcd binaries,  copy them to /usr/bin/local @etcd nodes etcd-1, etcd-2 & etcd-3

{
ETCD_VER=v3.4.13
ETCD_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${ETCD_URL}
ETCD_DOWNLOAD_DIR=./download

wget -q --show-progress --https-only --timestamping ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -P ../etcd/
tar xzf ${ETCD_DOWNLOAD_DIR}/etcd-${ETCD_VER}-linux-amd64.tar.gz -C ${ETCD_DOWNLOAD_DIR}/ --strip-components=1 

ETCD_SERVERS=
if [ $# -eq 0 ];
  then
    ETCD_SERVERS="etcd-1 etcd-2 etcd-3"
    echo "No arguments supplied - copying certs for $ETCD_SERVERS"
  else
    ETCD_SERVERS=$@
    echo "Copying certs for $ETCD_SERVERS"
fi

for instance in $ETCD_SERVERS; do
 lxc exec ${instance} -- systemctl daemon-reload
 lxc exec ${instance} -- systemctl stop etcd
 lxc file push ${ETCD_DOWNLOAD_DIR}/etcd ${ETCD_DOWNLOAD_DIR}/etcdctl ${instance}/usr/local/bin/
 COPIED=$?
 if [ $COPIED -ne 0 ]; then
   echo "Error while copying etcd binaries to ${instance}"
 else
    echo "Copied etcd binaries to ${instance}"
 fi
done

}

