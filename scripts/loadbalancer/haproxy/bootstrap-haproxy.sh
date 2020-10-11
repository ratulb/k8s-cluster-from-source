#!/usr/bin/env bash
. ../run-as-root.sh
#Install haproxy to front the kube-apiservers in the loadbalancer box
#Generate the systemd unit file and copy it to the loadbalancer box
#Start the haproxy service
. install-haproxy.sh
. gen-and-copy-haproxy-systemd-svc.sh
. start-haproxy.sh 
