#!/usr/bin/env bash

#Generates the certicates for the kubelets deployed on the worker nodes

WORKERS=
if [ $# -eq 0 ];
  then
    WORKERS="worker-1 worker-2 worker-3"
    echo "No arguments supplied - copying certs for $WORKERS"
  else
    WORKERS=$@
    echo "Copying certs for $WORKERS"
fi

GENERATED_DIR=../generated
mkdir -p ${GENERATED_DIR}

for instance in $WORKERS; do

cat > ${GENERATED_DIR}/${instance}-csr.json <<EOF
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
  -ca=${GENERATED_DIR}/ca.pem \
  -ca-key=${GENERATED_DIR}/ca-key.pem \
  -config=${GENERATED_DIR}/ca-config.json \
  -hostname=${instance},${INSTANCE_IP} \
  -profile=kubernetes \
  ${GENERATED_DIR}/${instance}-csr.json | cfssljson -bare ${GENERATED_DIR}/${instance}
done

