#!/usr/bin/env bash

#Generate data encryption key and associated configuration yaml master nodes/controller instances
#The generation and distribution is being taken care in this script
{

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

echo "Generated encryption yaml."

for instance in master-1 master-2 master-3; do
  lxc exec ${instance} -- mkdir -p /var/lib/kubernetes/
  lxc file push encryption-config.yaml ${instance}/var/lib/kubernetes/
done

echo "Encryption yaml copied to master nodes."

}
