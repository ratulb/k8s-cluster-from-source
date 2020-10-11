#!/usr/bin/env bash

#Generate and copy the kubelet systemd onfiguration to worker nodes

{

. ../run-as-root.sh
WORKERS=
if [ $# -eq 0 ];
  then
    WORKERS="worker-1 worker-2 worker-3"
    echo "No arguments supplied - setting up for $WORKERS"
  else
    WORKERS=$@
    echo "Setting up for $WORKERS"
fi

GENERATED_DIR=./generated/etc/systemd/system/

mkdir -p ${GENERATED_DIR}

cat <<EOF | tee ${GENERATED_DIR}/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

#Push the generated file to the current worker node

for instance in $WORKERS; do
lxc file push ${GENERATED_DIR}/kubelet.service ${instance}/etc/systemd/system/

echo "Kubelet systemd file copied to ${instance}"

done

}

