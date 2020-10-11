#!/usr/bin/env bash

#Install the kube-controller-manager binary in the master nodes
#create necessary directories, copy certs and
#create systemd service files and start the daemons
. distribute-kube-controller-manager-binary.sh
. distribute-kube-controller-manager-certs.sh
. gen-kube-controller-manager-config.sh
. distribute-kube-controller-manager-config.sh
. gen-and-distribute-kube-controller-manager-systemd-svc.sh
. start-kube-controller-managers.sh
