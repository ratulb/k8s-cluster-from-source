#!/usr/bin/env bash


#Generates the certicate for the loadbalancer node

{
cat > loadbalancer-csr.json <<EOF
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
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=loadbalancer,${INSTANCE_IP} \
  -profile=kubernetes \
  loadbalancer-csr.json | cfssljson -bare loadbalancer
}

