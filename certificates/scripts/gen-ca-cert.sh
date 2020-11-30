#!/usr/bin/env bash

# Generate certificate authority

GENERATED_DIR=../generated
mkdir -p ${GENERATED_DIR}

{
cat > ${GENERATED_DIR}/ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF
cat > ${GENERATED_DIR}/ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "IN",
      "L": "BLR",
      "O": "Kubernetes",
      "OU": "KA",
      "ST": "Karnataka"
    }
  ]
}
EOF
cfssl gencert -initca ${GENERATED_DIR}/ca-csr.json | cfssljson -bare ${GENERATED_DIR}/ca
}
