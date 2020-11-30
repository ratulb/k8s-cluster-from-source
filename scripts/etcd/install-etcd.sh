#!/usr/bin/env bash

#Get latest etcd binaries, install local machine

{
ETCD_VER=v3.4.14
ETCD_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${ETCD_URL}

rm -rf /tmp/etcd/
mkdir /tmp/etcd/

wget -q --show-progress --https-only --timestamping ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -P /tmp/
tar xzf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd/ --strip-components=1 

mv /tmp/etcd/etcd /tmp/etcd/etcdctl /usr/local/bin/


}

