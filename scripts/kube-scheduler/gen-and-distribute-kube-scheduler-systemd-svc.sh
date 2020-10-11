#!/usr/bin/env bash
#Generate the systemd service unit file for kube-scheduler and copy it to the master nodes

SERVICE_CLUSTER_IP_RANGE=10.32.0.0/24
CLUSTER_CIDR=10.200.0.0/16

cat <<EOF |tee ../systemd/kube-scheduler/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
  --config=/etc/kubernetes/config/kube-scheduler.yaml \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

for instance in master-1 master-2 master-3; do
 lxc file push ../systemd/kube-scheduler/kube-scheduler.service ${instance}/etc/systemd/system/
 echo "Copied the kube-scheduler service to ${instance}"
done

