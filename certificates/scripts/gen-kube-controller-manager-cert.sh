#!/usr/bin/env bash

#Generate kube-controller-manager certificate
{

GENERATED_DIR=../generated
mkdir -p ${GENERATED_DIR}

cat > ${GENERATED_DIR}/kube-controller-manager-csr.json <<EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:kube-controller-manager",
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
  -profile=kubernetes \
  ${GENERATED_DIR}/kube-controller-manager-csr.json | cfssljson -bare ${GENERATED_DIR}/kube-controller-manager

}

