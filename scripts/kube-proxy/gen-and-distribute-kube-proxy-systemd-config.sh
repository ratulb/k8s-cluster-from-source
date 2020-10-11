#!/usr/bin/env bash

#Generate and copy the kube-proxy systemd onfiguration to worker nodes

{
. ../run-as-root.sh
WORKERS=
if [ $# -eq 0 ];
  then
    WORKERS="worker-1 worker-2 worker-3"
  else
    WORKERS=$@
fi
echo "Setting up for $WORKERS"

GENERATED_DIR=./generated/etc/systemd/system/
mkdir -p ${GENERATED_DIR}

cat <<EOF | tee ${GENERATED_DIR}/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

#Push the generated file to the current worker node
for instance in $WORKERS; do
 lxc file push ${GENERATED_DIR}/kube-proxy.service ${instance}/etc/systemd/system/
 echo "Kube proxy systemd file copied to ${instance}"
done

}

