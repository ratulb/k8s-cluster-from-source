#!/usr/bin/env bash

#Generate the service-account certificate and private key

{

GENERATED_DIR=../generated
mkdir -p ${GENERATED_DIR}

cat > ${GENERATED_DIR}/service-account-csr.json <<EOF
{
  "CN": "service-accounts",
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
  -profile=kubernetes \
  ${GENERATED_DIR}/service-account-csr.json | cfssljson -bare ${GENERATED_DIR}/service-account

}


