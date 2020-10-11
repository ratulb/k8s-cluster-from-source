#!/usr/bin/env bash

#The kube scheduler certificate

{

GENERATED_DIR=../generated
mkdir -p ${GENERATED_DIR}

cat > kube-scheduler-csr.json <<EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:kube-scheduler",
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
  ${GENERATED_DIR}/kube-scheduler-csr.json | cfssljson -bare ${GENERATED_DIR}/kube-scheduler

}
