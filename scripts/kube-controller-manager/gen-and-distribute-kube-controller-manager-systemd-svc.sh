#!/usr/bin/env bash
#Generate the systemd service unit file for kube-controller-manager and copy it to the master nodes

SERVICE_CLUSTER_IP_RANGE=10.32.0.0/24
CLUSTER_CIDR=10.200.0.0/16

cat <<EOF | tee ../systemd/kube-controller-manager/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --bind-address=0.0.0.0 \\
  --cluster-cidr=${CLUSTER_CIDR} \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem \\
  --cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem \\
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  --leader-elect=true \\
  --root-ca-file=/var/lib/kubernetes/ca.pem \\
  --service-account-private-key-file=/var/lib/kubernetes/service-account-key.pem \\
  --service-cluster-ip-range=${SERVICE_CLUSTER_IP_RANGE} \\
  --use-service-account-credentials=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

for instance in master-1 master-2 master-3; do
 lxc file push ../systemd/kube-controller-manager/kube-controller-manager.service ${instance}/etc/systemd/system/
done

