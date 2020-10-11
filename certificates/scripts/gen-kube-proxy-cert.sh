#!/usr/bin/env bash

#The kube proxy certificate

{

GENERATED_DIR=../generated
mkdir -p ${GENERATED_DIR}

cat > ${GENERATED_DIR}/kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:node-proxier",
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
  ${GENERATED_DIR}/kube-proxy-csr.json | cfssljson -bare ${GENERATED_DIR}/kube-proxy

}

