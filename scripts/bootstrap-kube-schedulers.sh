#!/usr/bin/env bash

#Install the kube-scheduler binary in the master nodes
#create necessary directories, copy certs and
#create systemd service files and start the daemons
. distribute-kube-scheduler-binary.sh
. gen-kube-scheduler-config.sh
. distribute-kube-scheduler-config.sh
. gen-kube-scheduler-config-yaml-and-distribute.sh
. gen-and-distribute-kube-scheduler-systemd-svc.sh
. start-kube-schedulers.sh

