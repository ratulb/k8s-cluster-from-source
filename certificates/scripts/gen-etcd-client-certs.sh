#!/usr/bin/env bash

#Generates the certicates for etcd servers
ETCD_CLIENTS=
if [ $# -eq 0 ];
  then
    ETCD_CLIENTS="etcd-client"
    echo "No arguments supplied - creating certs for $ETCD_CLIENTS"
  else
    ETCD_CLIENTS=$@
    echo "Creating certs for $ETCD_CLIENTS"
fi

GENERATED_DIR=../generated
mkdir -p ${GENERATED_DIR}

for instance in $ETCD_CLIENTS; do

cat > ${GENERATED_DIR}/${instance}-csr.json <<EOF
{
  "CN": "${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "IN",
      "L": "BLR",
      "O": "etcd-server",
      "OU": "k8s-cluster-from-source",
      "ST": "karnataka"
    }
  ]
}
EOF

INSTANCE_IP=$instance

cfssl gencert \
  -ca=${GENERATED_DIR}/ca.pem \
  -ca-key=${GENERATED_DIR}/ca-key.pem \
  -config=${GENERATED_DIR}/ca-config.json \
  -hostname=${instance},${INSTANCE_IP} \
  -profile=kubernetes \
  ${GENERATED_DIR}/${instance}-csr.json | cfssljson -bare ${GENERATED_DIR}/${instance}
done

