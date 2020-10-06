#!/usr/bin/env bash

#Install the etcd binaries in the etcd boxes 
#create necessary directories, copy certs and
#create systemd service files and start the daemons

. ../../etcd/copy-etcd-binaries.sh
. ../../etcd/init-etcd-data-dir.sh
cd ../../certificates/
. distribute-etcd-certs.sh
cd -

#Generate systemd files

. gen-and-copy-etcd-systemd-svc.sh
. start-etcd.sh
