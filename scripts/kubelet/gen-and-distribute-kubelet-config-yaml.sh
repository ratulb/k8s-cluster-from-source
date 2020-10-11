#!/usr/bin/env bash

#Generate and copy the kubelet yaml onfiguration to worker nodes

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

GENERATED_DIR=./generated/var/lib/kubelet/

mkdir -p ${GENERATED_DIR}

SEED_CIDR=10.200
COUNTER=1

for instance in $WORKERS; do
POD_CIDR=${SEED_CIDR}.${COUNTER}.0/24

cat <<EOF | tee ${GENERATED_DIR}/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "${POD_CIDR}"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/${instance}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/${instance}-key.pem"
EOF


((COUNTER++))

#Push the generated file to the current worker node

cp ${GENERATED_DIR}/kubelet-config.yaml ${GENERATED_DIR}/kubelet-config.yaml.${instance}

lxc file push ${GENERATED_DIR}/kubelet-config.yaml ${instance}/var/lib/kubelet/

echo "Kubelet yaml configuration copied to ${instance}"

done

}

