#!/usr/bin/env bash

#Generate and copy the kubelet yaml onfiguration to worker nodes

{

. ../run-as-root.sh
WORKERS=
if [ $# -eq 0 ];
#!/usr/bin/env bash
  then
#!/usr/bin/env bash
    WORKERS="worker-1 worker-2 worker-3"
    echo "No arguments supplied - setting up for $WORKERS"
  else
    WORKERS=$@
    echo "Setting up for $WORKERS"
fi

GENERATED_DIR=./generated/etc/containerd
mkdir -p ${GENERATED_DIR}

cat << EOF | tee ${GENERATED_DIR}/config.toml
[plugins]
  [plugins.cri.containerd]
    snapshotter = "native"
    [plugins.cri.containerd.default_runtime]
      runtime_type = "io.containerd.runtime.v1.linux"
      runtime_engine = "/usr/local/sbin/runc"
      runtime_root = ""
EOF

GENERATED_FOR_KUBELET_CONF=/etc/systemd/system/kubelet.service.d
mkdir - ${GENERATED_FOR_KUBELET_CONF}

cat << EOF | tee ${GENERATED_FOR_KUBELET_CONF}/0-containerd.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--container-runtime=remote --runtime-request-timeout=15m --container-runtime-endpoint=unix:///run/containerd/containerd.sock"
EOF

for instance in $WORKERS; do

#Push the generated file to the current worker node

lxc exec ${instance} -- mkdir -p /etc/containerd/
lxc file push ${GENERATED_DIR}/config.toml ${instance}/etc/containerd/

echo "Container config.toml  configuration copied to ${instance}"

lxc exec ${instance} -- mkdir -p /etc/systemd/system/kubelet.service.d/
lxc file push ${GENERATED_FOR_KUBELET_CONF}/0-containerd.conf ${instance}/etc/systemd/system/kubelet.service.d/

echo "Kubelet 0-container.conf pushed to /etc/systemd/system/kubelet.service.d/ in ${instance}"

done

}

