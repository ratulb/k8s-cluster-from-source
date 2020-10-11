#!/usr/bin/env bash

#Generates the certicates for the kubelets deployed on the worker nodes
ETCD_SERVERS=
if [ $# -eq 0 ];
  then
    ETCD_SERVERS="etcd-1 etcd-2 etcd-3"
    echo "No arguments supplied - copying certs for $ETCD_SERVERS"
  else
    ETCD_SERVERS=$@
    echo "Copying certs for $ETCD_SERVERS"
fi

GENERATED_DIR=../generated
mkdir -p ${GENERATED_DIR}

for instance in $ETCD_SERVERS; do

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

