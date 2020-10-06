#!/usr/bin/env bash

#Install the kube-apiserver binary in the master nodes
#create necessary directories, copy certs and
#create systemd service files and start the daemons

. copy-kube-apiserver-binary.sh
. distribute-master-certs.sh
. gen-encryption-config-and-copy.sh
. gen-and-copy-kube-apiserver-systemd-svc.sh
. start-api-servers.sh 
