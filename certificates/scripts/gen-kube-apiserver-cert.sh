#!/usr/bin/env bash

#Generate the kube-apiserver certificate

{

GENERATED_DIR=../generated

mkdir -p ${GENERATED_DIR}

KUBERNETES_PUBLIC_ADDRESS=$(lxc list | grep loadbalancer | awk '{print $6}')
MASTER1_IP_ADDRESS=$(lxc list | grep master-1 | awk '{print $6}')
MASTER2_IP_ADDRESS=$(lxc list | grep master-2 | awk '{print $6}')
MASTER3_IP_ADDRESS=$(lxc list | grep master-3 | awk '{print $6}')

KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local

cat > ${GENERATED_DIR}/kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Kubernetes cluster ground up from sources",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=${GENERATED_DIR}/ca.pem \
  -ca-key=${GENERATED_DIR}/ca-key.pem \
  -config=${GENERATED_DIR}/ca-config.json \
  -hostname=${MASTER1_IP_ADDRESS},${MASTER2_IP_ADDRESS},${MASTER3_IP_ADDRESS},${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES} \
  -profile=kubernetes \
  ${GENERATED_DIR}/kubernetes-csr.json | cfssljson -bare ${GENERATED_DIR}/kubernetes

}

