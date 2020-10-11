#!/usr/bin/env bash

#Bootstrap the kube-proxy service on the worker nodes

. distribute-kube-proxy-binary.sh
. gen-kube-proxy-config.sh
. distribute-kube-proxy-config.sh
. gen-and-distribute-kube-proxy-config-yaml.sh
. gen-and-distribute-kubelet-systemd-config.sh
. gen-and-distribute-kube-proxy-systemd-config.sh
#. start-kube-proxies.sh
