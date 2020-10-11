#!/usr/bin/env bash
. run-as-root.sh
#Install the kube-apiserver binary in the master nodes
#create necessary directories, copy certs and
#create systemd service files and start the daemons

. distribute-kube-apiserver-binary.sh
. distribute-master-certs.sh
. gen-admin-config.sh
. distribute-admin-config-and-kubectl.sh
. gen-encryption-config-and-distribute.sh
. gen-and-distribute-kube-apiserver-systemd-svc.sh
. start-api-servers.sh 
