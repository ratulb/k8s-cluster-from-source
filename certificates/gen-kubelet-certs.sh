#!/usr/bin/env bash


#Generates the certicates for the kubelets deployed on the worker nodes

for instance in worker-1 worker-2 worker-3; do

cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
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

INSTANCE_IP=$(lxc list | grep ${instance} | awk '{print $6}')


cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${instance},${INSTANCE_IP} \
  -profile=kubernetes \
  ${instance}-csr.json | cfssljson -bare ${instance}
done

