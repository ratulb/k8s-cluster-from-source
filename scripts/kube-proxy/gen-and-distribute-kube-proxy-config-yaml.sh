#!/usr/bin/env bash

#Generate and copy the kube-proxy yaml onfiguration to worker nodes

{

. ../run-as-root.sh
WORKERS=
if [ $# -eq 0 ];
#!/usr/bin/env bash
  then
#!/usr/bin/env bash
    WORKERS="worker-1 worker-2 worker-3"
    echo "No arguments supplied - setting up for $WORKERS"
  else
    WORKERS=$@
    echo "Setting up for $WORKERS"
fi

GENERATED_DIR=./generated/var/lib/kube-proxy

mkdir -p ${GENERATED_DIR}

for instance in $WORKERS; do

cat <<EOF | tee ${GENERATED_DIR}/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "10.200.0.0/16"
EOF

#Push the generated file to the current worker node
lxc file push ${GENERATED_DIR}/kube-proxy-config.yaml ${instance}/var/lib/kube-proxy/
echo "Kube proxy yaml configuration copied to ${instance}"
done

}

