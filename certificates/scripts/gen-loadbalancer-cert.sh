#!/usr/bin/env bash


#Generates the certicate for the loadbalancer node

{

GENERATED_DIR=../generated
mkdir -p ${GENERATED_DIR}

cat > ${GENERATED_DIR}/loadbalancer-csr.json <<EOF
{
  "CN": "system:node:loadbalancer",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
      "OU": "kubernetes-cluster-ground-up-from-sources",
      "ST": "Oregon"
    }
  ]
}
EOF

INSTANCE_IP=$(lxc list | grep loadbalancer | awk '{print $6}')


cfssl gencert \
  -ca=${GENERATED_DIR}/ca.pem \
  -ca-key=${GENERATED_DIR}/ca-key.pem \
  -config=${GENERATED_DIR}/ca-config.json \
  -hostname=loadbalancer,${INSTANCE_IP} \
  -profile=kubernetes \
  ${GENERATED_DIR}/loadbalancer-csr.json | cfssljson -bare ${GENERATED_DIR}/loadbalancer
}

