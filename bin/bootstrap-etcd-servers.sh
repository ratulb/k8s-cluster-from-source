#!/usr/bin/env bash
. run-as-root.sh
#Download the etcd release tar file, extract the etcd & etcdctl binaries
#Copy the binaries to etcd nodes
#create necessary directories, copy certs and
#create systemd service files and start the daemons

. distribute-etcd-binary.sh
. init-etcd-data-dir.sh
. distribute-etcd-certs.sh
. gen-and-distribute-etcd-systemd-svc.sh
. start-etcd-servers.sh 
