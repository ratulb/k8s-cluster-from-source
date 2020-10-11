#!/usr/bin/env bash

#Install the os-dependences, cri/containerd/cni on the worker nodes
#create necessary directories, copy certs, configs, bridge network configs  
#create systemd service files and start the daemons


. install-os-dependencies.sh
. install-cri-containerd-cni.sh
. make-kubelet-dirs.sh
. distribute-kubelet-certs.sh
. gen-kubelet-configs.sh
. distribute-kubelet-configs.sh
. distribute-kubelet-binary.sh
. gen-and-distribute-kubelet-bridge-config.sh
. gen-and-distribute-kubelet-config-yaml.sh
. gen-and-distribute-kubelet-systemd-config.sh
. gen-and-distribute-containerd-config.sh
. ../../lxd/lxd-config-kubelet-boxes.sh
. start-containerd-and-kublets.sh
. reboot-kubelet-boxes.sh
