#!/usr/bin/env bash
#Generate the etcd systemd service unit file for kube-apiserver and copy it to the master nodes

ETCD1_IP=$(lxc list | grep etcd-1 | awk '{print $6}')
ETCD2_IP=$(lxc list | grep etcd-2 | awk '{print $6}')
ETCD3_IP=$(lxc list | grep etcd-3 | awk '{print $6}')
ETCD_SERVERS=https://${ETCD1_IP}:2379,https://${ETCD2_IP}:2379,https://${ETCD3_IP}:2379
SERVICE_CLUSTER_IP_RANGE=10.32.0.0/24

for instance in master-1 master-2 master-3; do
 
 INTERNAL_IP=$(lxc list | grep ${instance} | awk '{print $6}')
 
 cat <<EOF | tee ../systemd/kube-apiserver/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${INTERNAL_IP} \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --etcd-cafile=/var/lib/kubernetes/ca.pem \\
  --etcd-certfile=/var/lib/kubernetes/kubernetes.pem \\
  --etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem \\
  --etcd-servers=${ETCD_SERVERS} \\
  --event-ttl=1h \\
  --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
  --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \\
  --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \\
  --kubelet-https=true \\
  --runtime-config='api/all=true' \\
  --service-account-key-file=/var/lib/kubernetes/service-account.pem \\
  --service-cluster-ip-range=${SERVICE_CLUSTER_IP_RANGE} \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \\
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

cp ../systemd/kube-apiserver/kube-apiserver.service ../systemd/kube-apiserver/kube-apiserver-${instance}.service

lxc file push ../systemd/kube-apiserver/kube-apiserver.service ${instance}/etc/systemd/system/
done

