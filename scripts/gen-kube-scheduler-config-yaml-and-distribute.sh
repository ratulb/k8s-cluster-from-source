#!/usr/bin/env bash

#Generate kube-scheduler.yaml and copy it to the master nodes

{
cat <<EOF | tee ../systemd/kube-scheduler/kube-scheduler.yaml
apiVersion: kubescheduler.config.k8s.io/v1beta1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true
EOF

echo "Generated kube scheduler config yaml."

for instance in master-1 master-2 master-3; do
  lxc exec ${instance} -- mkdir -p /etc/kubernetes/config
  lxc file push ../systemd/kube-scheduler/kube-scheduler.yaml ${instance}/etc/kubernetes/config/
  echo "Kube scheduler config yaml copied to ${instance}."
done
}
