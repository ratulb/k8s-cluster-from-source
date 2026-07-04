# Kubernetes Cluster on LXD from Latest Sources

Build a multi-node, production-adjacent Kubernetes cluster **from source code** and run it on LXD containers — all without kubeadm, kubelet bootstrap, or any installer tooling.

## Motivation

This project exists for one reason: **to understand Kubernetes by building it from scratch**.

When you run `kubeadm init`, a thousand things happen behind your back. A CA is generated, certificates are issued, kubeconfigs are wired, manifests are templated, components are started. It works, but it teaches you almost nothing about the system you are running.

This repository takes the opposite approach. Every certificate, every kubeconfig, every systemd unit, every flag passed to every binary — it is all generated in plain sight by shell scripts you can read, modify, and debug. The cluster is built in the same order the Kubernetes control plane actually starts: etcd first, then the API server, then the controller manager, then the scheduler, then the workers, then the proxy.

Beyond pedagogical value, building from source means you can:
- Test patches or experimental branches against a real multi-node cluster, not just unit tests.
- Add custom admission plugins, audit backends, or scheduler algorithms and run them immediately.
- Replicate bug reports with exact commit SHAs.
- Build Kubelets for ARM or cross-compile for edge hardware.

The cluster targets Ubuntu 18.04/20.04 hosts with LXD, but the scripts are straightforward enough to adapt to raw VMs or bare metal with minor path changes.

## Architecture

### Container topology

```
┌─────────────────────────────────────────────────┐
│                  LXD Host                        │
│                                                  │
│  ┌──────┐  ┌──────┐  ┌──────┐                   │
│  │etcd-1│  │etcd-2│  │etcd-3│                   │
│  └──┬───┘  └──┬───┘  └──┬───┘                   │
│     └─────────┼──────────┘                       │
│               │ mTLS (port 2379 client,          │
│               │       2380 peer)                  │
│  ┌──────────────────────────────────────┐        │
│  │           Master Nodes               │        │
│  │  ┌──────────┐ ┌──────────┐ ┌───────┐ │        │
│  │  │ master-1 │ │ master-2 │ │master-3│ │        │
│  │  │  APISvr  │ │  APISvr  │ │APISvr  │ │        │
│  │  │  C-Mgr   │ │  C-Mgr   │ │C-Mgr   │ │        │
│  │  │ Scheduler│ │ Scheduler│ │Scheduler│ │        │
│  │  └────┬─────┘ └────┬─────┘ └───┬────┘ │        │
│  └───────┼──────────────┼──────────┼──────┘        │
│          └──────┬───────┘                          │
│                 │ TCP 6443                          │
│         ┌───────┴────────┐                         │
│         │  loadbalancer   │                         │
│         │   HAProxy :6443 │                         │
│         └───────┬────────┘                         │
│                 │                                    │
│  ┌──────────────┼─────────────────────────┐         │
│  │         Worker Nodes                   │         │
│  │  ┌──────────┐ ┌──────────┐ ┌─────────┐ │         │
│  │  │ worker-1 │ │ worker-2 │ │ worker-3│ │         │
│  │  │ kubelet  │ │ kubelet  │ │ kubelet │ │         │
│  │  │ kube-proxy│ │ kube-proxy│ │kube-proxy│        │
│  │  │ containerd│ │ containerd│ │containerd│        │
│  │  └──────────┘ └──────────┘ └─────────┘ │         │
│  └─────────────────────────────────────────┘         │
└─────────────────────────────────────────────────────┘
```

### IP assignments and CIDR plan

| Parameter | Value |
|---|---|
| Service cluster CIDR | `10.32.0.0/24` |
| Cluster (Pod) CIDR | `10.200.0.0/16` |
| Cluster DNS (CoreDNS placeholder) | `10.32.0.10` |
| NodePort range | `30000–32767` |
| Worker-1 pod CIDR | `10.200.1.0/24` |
| Worker-2 pod CIDR | `10.200.2.0/24` |
| Worker-3 pod CIDR | `10.200.3.0/24` |

All LXD containers receive IPs from the `lxdbr0` bridge. The loadbalancer and master IPs are discovered dynamically via `lxc list` and injected into configurations at generation time.

### TLS certificate map

| Certificate | CN | Used by | Key usage |
|---|---|---|---|
| CA | `Kubernetes` | Every component trusts this | signing |
| admin | `admin` (O=`system:masters`) | Admin user → API server | client auth |
| kube-apiserver | `kubernetes` | API server serving cert | server auth |
| kubelet (×3) | `system:node:worker-N` | Each kubelet | server + client auth |
| kube-controller-manager | `system:kube-controller-manager` | Controller manager | client auth |
| kube-scheduler | `system:kube-scheduler` | Scheduler | client auth |
| kube-proxy | `system:kube-proxy` | Kube-proxy | client auth |
| service-account | `service-accounts` | Service account token signing | key pair only |
| etcd-server (×3) | `etcd-N` | etcd peer + client | server + client auth |
| etcd-client | `etcd-client` | API server → etcd | client auth |
| loadbalancer | `system:node:loadbalancer` | Optional HAProxy TLS | client auth |

### How components discover each other

| Connection | Mechanism |
|---|---|
| API server → etcd | HTTPS via kubernetes cert + CA, URLs resolved from script-generated `--etcd-servers` |
| Scheduler → API server | Loopback `https://127.0.0.1:6443` via `kube-scheduler.kubeconfig` |
| Controller manager → API server | Loopback `https://127.0.0.1:6443` via `kube-controller-manager.kubeconfig` |
| Kubelet → API server | HAProxy loadbalancer IP via `worker-N.kubeconfig` |
| Kube-proxy → API server | HAProxy loadbalancer IP via `kube-proxy.kubeconfig` |
| Admin (kubectl) → API server | HAProxy or loopback via `admin.kubeconfig` |
| API server → kubelet | Direct HTTPS to worker IP (ClusterRole `system:kube-apiserver-to-kubelet`) |
| Workers → pods | CNI bridge `cnio0` with host-local IPAM |

## Prerequisites

- **Host**: Ubuntu 18.04 or 20.04 with LXD installed (`snap install lxd` or `apt install lxd`).
- **LXD initialized**: `lxd init` with a storage pool and network bridge (`lxdbr0`).
- **LXD containers created** and **running** with the following hostnames:

  | Group | Container names |
  |---|---|
  | etcd | `etcd-1` `etcd-2` `etcd-3` |
  | control plane | `master-1` `master-2` `master-3` |
  | workers | `worker-1` `worker-2` `worker-3` |
  | load balancer | `loadbalancer` |

- **Root access**: Almost every script calls `scripts/run-as-root.sh` which checks `$(id -u) = 0`.

> **Note**: Container provisioning is **not** automated. You must create the containers yourself (`lxc launch ubuntu:20.04 <name>`) before running any bootstrap scripts. Each container needs a working `apt-get`.

## Flow — End to End

There are three phases: **build**, **certificates**, and **bootstrap**.

### Phase 1: Build Kubernetes binaries

```bash
cd scripts/kube-build
./build-binaries.sh
```

What happens internally:
1. Clones `https://github.com/kubernetes/kubernetes.git --depth 1` into `scripts/kube-build/kubernetes/` (or `git pull` if already cloned).
2. Installs Docker if not present (via `install-docker.sh` using the get.docker.com script).
3. Inside the cloned source tree, runs `build/run.sh make` for every target: `kubeadm`, `kubelet`, `kubectl`, `kube-controller-manager`, `kube-proxy`, `kube-scheduler`, `kube-apiserver`.
4. Moves the binaries from `_output/dockerized/bin/linux/amd64/` to `kube-binaries/`.

> **Tip**: Pass a single target to build only one binary, e.g. `./build-binaries.sh kubelet`. Use `./build-binaries.sh kube-apiserver` if you only changed the API server.

### Phase 2: Generate certificates

```bash
cd certificates/scripts
./install-cfssl-cfssljson.sh
./gen-ca-cert.sh
./gen-admin-cert.sh
./gen-kubelet-certs.sh
./gen-kube-controller-manager-cert.sh
./gen-kube-proxy-cert.sh
./gen-kube-scheduler-cert.sh
./gen-kube-apiserver-cert.sh
./gen-service-account-cert.sh
./gen-loadbalancer-cert.sh
./gen-etcd-svr-certs.sh
./gen-etcd-client-certs.sh
```

All output PEMs, keys, and CSR JSON land in `certificates/generated/`.

Key detail — the API server cert is the most complex: its SAN list includes all three master IPs, the loadbalancer IP, `127.0.0.1`, and the Kubernetes service DNS names (`kubernetes`, `kubernetes.default`, etc.). These are discovered live from `lxc list`, so containers must be running.

### Phase 3: Bootstrap each tier (sequential)

Run these from the repo root:

```bash
# 1. etcd cluster (3-node, mTLS peer + client)
. scripts/etcd/bootstrap-etcd-servers.sh

# 2. kube-apiserver (3-node, active-active)
. scripts/kube-apiserver/bootstrap-kube-apiservers.sh

# 3. kube-controller-manager (3-node, leader-elected)
. scripts/kube-controller-manager/bootstrap-kube-controller-managers.sh

# 4. kube-scheduler (3-node, leader-elected)
. scripts/kube-scheduler/bootstrap-kube-schedulers.sh

# 5. HAProxy loadbalancer (1-node)
. scripts/loadbalancer/haproxy/bootstrap-haproxy.sh

# 6. kubelet + containerd + CNI (3-node)
. scripts/kubelet/bootstrap-kubelets.sh

# 7. kube-proxy (3-node)
. scripts/kube-proxy/bootstrap-kube-proxies.sh
```

> **IMPORTANT**: After bootstrapping kubelets, apply the RBAC rules on the cluster before nodes show healthy (otherwise the API server cannot authenticate to kubelets for `kubectl logs`, `kubectl exec`, etc.):
>
> ```bash
> kubectl apply -f cluster-mgnt/cluster/roles/kube-apiserver-to-kubelet.yaml
> kubectl apply -f cluster-mgnt/cluster/bindings/kube-apiserver-to-kubelet.yaml
> ```

## Deep dive — what each bootstrap step does

### 1. etcd (`scripts/etcd/bootstrap-etcd-servers.sh`)

| Sub-step | What it does |
|---|---|
| `distribute-etcd-binary.sh` | Downloads etcd `v3.4.14` from GitHub, extracts to `scripts/etcd/download/`, pushes `etcd` and `etcdctl` to each etcd container's `/usr/local/bin/` |
| `init-etcd-data-dir.sh` | `rm -rf /var/lib/etcd; mkdir -p /var/lib/etcd; chmod 700` on each etcd node |
| `distribute-etcd-certs.sh` | Pushes `ca.pem`, `<node>.pem`, `<node>-key.pem` to `/etc/etcd/` on each node |
| `gen-and-distribute-etcd-systemd-svc.sh` | Generates a systemd unit for each node with `--initial-cluster` pointing to all three peer URLs. Node name and IP are injected per-node |
| `start-etcd-servers.sh` | `daemon-reload`, `enable`, `start` etcd on all three nodes |

The etcd cluster uses:
- TLS client authentication (`--client-cert-auth`, `--peer-client-cert-auth`)
- Explicit `--initial-cluster-state new` (do not re-run on an already-initialized data directory without changing this to `existing`)
- A static cluster token `etcd-cluster-0`

### 2. kube-apiserver (`scripts/kube-apiserver/bootstrap-kube-apiservers.sh`)

| Sub-step | What it does |
|---|---|
| `distribute-kube-apiserver-binary.sh` | Pushes the built `kube-apiserver` binary to each master |
| `distribute-master-certs.sh` | Pushes `ca.pem`, `ca-key.pem`, `kubernetes-key.pem`, `kubernetes.pem`, `service-account-key.pem`, `service-account.pem` to `/var/lib/kubernetes/` |
| `gen-admin-config.sh` | Creates `admin.kubeconfig` via `kubectl config set-*` commands (server = `https://127.0.0.1:6443`) |
| `distribute-admin-config-and-kubectl.sh` | Pushes `admin.kubeconfig` and the built `kubectl` binary to each master |
| `gen-encryption-config-and-distribute.sh` | Generates a 32-byte random AES-CBC key, writes `encryption-config.yaml`, pushes to `/var/lib/kubernetes/` on each master |
| `gen-and-distribute-kube-apiserver-systemd-svc.sh` | Generates a systemd unit with all flags: encryption provider, audit logging, admission plugins (`NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota`), ETCD servers, kubelet auth, RBAC + Node authorization |
| `start-api-servers.sh` | Starts the API server on all three masters |

Flags worth knowing:
- `--authorization-mode=Node,RBAC` — Node authorizer for kubelet self-identification, RBAC for everything else.
- `--enable-admission-plugins=...NodeRestriction...` — Kubelets can only modify their own Node object.
- `--encryption-provider-config` — Secrets are encrypted at rest with AES-CBC.
- `--runtime-config=api/all=true` — Enables all API groups.

### 3. kube-controller-manager

Pushes binary, certificates, generates its kubeconfig (pointing to `127.0.0.1:6443`), pushes config files, generates and pushes systemd unit. Starts with `--leader-elect=true`.

Key config:
- `--cluster-cidr=10.200.0.0/16` — The pod network CIDR (used by the controller manager to allocate Node `spec.podCIDR`s, though this repo assigns pod CIDRs statically per kubelet config).
- `--service-cluster-ip-range=10.32.0.0/24` — Service IP allocation range.
- `--cluster-signing-cert-file` / `--cluster-signing-key-file` — The CA used to sign kubelet serving CSRs.

### 4. kube-scheduler

Pushes binary, generates kubeconfig, generates `kube-scheduler.yaml` (v1beta1 `KubeSchedulerConfiguration` with leader election), pushes config, generates systemd unit. Starts with leader election.

The scheduler references its config file via `--config=/etc/kubernetes/config/kube-scheduler.yaml`.

### 5. loadbalancer

Installs HAProxy on the `loadbalancer` container via `apt-get install haproxy`. Generates `haproxy.cfg` with the three master IPs (discovered live) as backends for TCP port 6443. Enables `ip_nonlocal_bind` on the loadbalancer.

### 6. kubelet + containerd + CNI (`scripts/kubelet/bootstrap-kubelets.sh`)

This is the most complex bootstrap (21 sub-steps):

| Sub-step | What it does |
|---|---|
| `install-os-dependencies.sh` | `apt-get install libseccomp2 socat conntrack ipset` |
| `install-cri-containerd-cni.sh` | Downloads and extracts `cri-containerd-cni-1.3.4.linux-amd64.tar.gz` on each worker. Configures containerd systemd unit (disables `modprobe overlay` workaround for LXD). Enables and starts containerd |
| `make-kubelet-dirs.sh` | Creates CNI, kubelet, kube-proxy, kubernetes directories. Pushes `/dev/kmsg` → `/dev/console` tmpfiles config |
| `distribute-kubelet-certs.sh` | Pushes per-worker `.pem` + `-key.pem` to `/var/lib/kubelet/`, `ca.pem` to `/var/lib/kubernetes/` |
| `gen-kubelet-configs.sh` | Generates per-worker kubeconfig files targeting the HAProxy loadbalancer (`CN=system:node:<worker>`) |
| `distribute-kubelet-configs.sh` | Pushes per-worker kubeconfig as `/var/lib/kubelet/kubeconfig` |
| `distribute-kubelet-binary.sh` | Pushes `kubelet` to `/usr/local/bin/` |
| `gen-and-distribute-kubelet-bridge-config.sh` | Generates CNI bridge config (`10-bridge.conf`) with a unique `/24` per worker: `10.200.1.0/24`, `10.200.2.0/24`, `10.200.3.0/24`. Also `99-loopback.conf` |
| `gen-and-distribute-kubelet-config-yaml.sh` | Generates `kubelet-config.yaml` per worker with `podCIDR`, `tlsCertFile`, `tlsPrivateKeyFile`, `authentication` (webhook + x509), `authorization` (webhook), cluster DNS at `10.32.0.10` |
| `gen-and-distribute-kubelet-systemd-config.sh` | Generates `kubelet.service` specifying `--container-runtime=remote`, `--container-runtime-endpoint=unix:///var/run/containerd/containerd.sock`, `--network-plugin=cni` |
| `gen-and-distribute-containerd-config.sh` | Generates containerd `config.toml` with `snapshotter = "native"` and `runtime_engine = "/usr/local/sbin/runc"`. Also pushes `0-containerd.conf` drop-in to `/etc/systemd/system/kubelet.service.d/` |
| `../../lxd/lxd-config-kubelet-boxes.sh` | Configures LXD kernel modules (`ip_tables, ip6_tables, netlink_diag, nf_nat, overlay`), raw LXC (`apparmor=unconfined, cap.drop=, cgroup devices allow a`), and `security.privileged=true` |
| `start-containerd-and-kublets.sh` | Enables and starts containerd then kubelet |
| `reboot-kubelet-boxes.sh` | `lxc exec <worker> reboot` |

### 7. kube-proxy

Distributes binary, generates kubeconfig (pointing to HAProxy), distributes config, generates `kube-proxy-config.yaml` (iptables mode, cluster CIDR `10.200.0.0/16`), generates systemd unit.

> **Note**: The bootstrap script has `#. start-kube-proxies.sh` commented out. You must manually start kube-proxy or run `./scripts/kube-proxy/start-kube-proxies.sh` after bootstrap.

## Cluster start / stop

The start script re-enables and re-starts services in this order:

```
workers (kubelet, kube-proxy) → masters (apiserver, scheduler, controller-manager) → etcd → loadbalancer (haproxy)
```

The shutdown script stops them in the same order.

```bash
./scripts/start-cluster.sh
./scripts/shutdown-cluster.sh
```

Both use `lxc exec <instance> -- systemctl <start|stop> <service>`.

## Verifying the cluster

```bash
# On any master node (kubectl is pre-installed):
lxc exec master-1 -- kubectl get nodes --kubeconfig=admin.kubeconfig
lxc exec master-2 -- kubectl get componentstatuses --kubeconfig=admin.kubeconfig

# Test etcd connectivity:
. scripts/etcd/test-etcd-connectivity.sh

# Apply sample nginx deployment:
lxc exec master-1 -- kubectl apply -f deployments/nginx-with-ping-deployment.yaml --kubeconfig=admin.kubeconfig
```

## Debugging guide

### Component won't start

All components run as systemd services. Common checks:

```bash
lxc exec <node> -- systemctl status <service>
lxc exec <node> -- journalctl -u <service> -n 100 --no-pager
```

| Symptom | Likely cause |
|---|---|
| etcd fails to start | Data directory `/var/lib/etcd` already initialized from a prior run with a different cluster token. Remove it: `lxc exec etcd-N -- rm -rf /var/lib/etcd` and re-run the init step. Or change `--initial-cluster-state` from `new` to `existing`. |
| API server fails | etcd not reachable. Verify etcd IPs in the systemd unit match actual container IPs. Check that `encryption-config.yaml` has the correct base64 key. |
| Kubelet fails | Certificate mismatch: verify the CN is `system:node:<worker-N>` and the cert is signed by the same CA the API server trusts. Check containerd is running. |
| Kube-proxy fails | Config YAML has wrong cluster CIDR or kubeconfig points to wrong loadbalancer IP. |
| `kubectl exec` or `logs` hangs | The ClusterRole/ClusterRoleBinding `system:kube-apiserver-to-kubelet` is missing. Apply the manifests in `cluster-mgnt/`. |
| Nodes show `NotReady` | Kubelet cannot reach the API server (check HAProxy IP in the kubeconfig). Or CNI bridge config has incorrect pod CIDR. Or swap is on. |
| pods stuck in `ContainerCreating` | containerd not running, or CNI binaries not in `/opt/cni/bin/`, or bridge config missing. |

### Rebuilding individual binaries

If you changed one component:

```bash
./scripts/kube-build/build-binaries.sh kubelet    # rebuild only kubelet
```

Then re-run only the subset of bootstrap steps that distribute that binary:

```bash
# For example, pushing a new kubelet to workers:
. scripts/kubelet/distribute-kubelet-binary.sh
. scripts/kubelet/start-containerd-and-kublets.sh
```

### Regenerating a single kubeconfig

If you need to regenerate e.g. the admin kubeconfig with new certs:

```bash
. scripts/kube-apiserver/gen-admin-config.sh
```

### Reset a node completely

```bash
lxc exec worker-1 -- systemctl stop kubelet kube-proxy
lxc exec worker-1 -- rm -rf /var/lib/kubelet /var/lib/kube-proxy /etc/cni/net.d/
```

Then re-run the relevant bootstrap step.

## File tree reference

```
.
├── AGENTS.md                     # Instructions for AI coding agents
├── README.md                     # This file
├── .gitignore                    # Ignores *.csr, *.pem, *.json, *.bak, generated dirs
│
├── certificates/
│   ├── certificate-template.txt  # Reference: all CSR/CA templates concatenated
│   ├── scripts/
│   │   ├── install-cfssl-cfssljson.sh
│   │   ├── gen-ca-cert.sh
│   │   ├── gen-admin-cert.sh
│   │   ├── gen-kubelet-certs.sh
│   │   ├── gen-kube-controller-manager-cert.sh
│   │   ├── gen-kube-proxy-cert.sh
│   │   ├── gen-kube-scheduler-cert.sh
│   │   ├── gen-kube-apiserver-cert.sh
│   │   ├── gen-service-account-cert.sh
│   │   ├── gen-loadbalancer-cert.sh
│   │   ├── gen-etcd-svr-certs.sh
│   │   └── gen-etcd-client-certs.sh
│   └── generated/                # Output (gitignored)
│
├── kubeconfigs/                  # Pre-generated/regenerated kubeconfigs
│   ├── admin.kubeconfig
│   ├── kube-controller-manager.kubeconfig
│   ├── kube-proxy.kubeconfig
│   └── kube-scheduler.kubeconfig
│
├── encryption/
│   └── encryption-config.yaml    # AES-CBC encryption config for Secrets
│
├── systemd/                      # Generated systemd unit files
│   ├── etcd/etcd.service
│   ├── kube-apiserver/kube-apiserver.service
│   ├── kube-controller-manager/kube-controller-manager.service
│   └── kube-scheduler/
│       ├── kube-scheduler.service
│       └── kube-scheduler.yaml
│
├── lxd/
│   ├── lxd-profile-default.yaml          # Default LXD profile
│   └── lxd-config-kubelet-boxes.sh       # LXD kernel/config for workers
│
├── scripts/
│   ├── run-as-root.sh                    # Root guard (sourced by others)
│   ├── start-cluster.sh                  # Start all services
│   ├── shutdown-cluster.sh               # Stop all services
│   │
│   ├── kube-build/
│   │   ├── build-binaries.sh             # Clone k8s source + build binaries
│   │   ├── install-docker.sh             # Docker install/activation
│   │   ├── kubernetes/                   # Cloned k8s repo (gitignored)
│   │   └── README.md
│   │
│   ├── etcd/
│   │   ├── bootstrap-etcd-servers.sh     # Master bootstrap script
│   │   ├── distribute-etcd-binary.sh     # Download + push etcd binary
│   │   ├── install-etcd.sh               # Install locally (alternative)
│   │   ├── init-etcd-data-dir.sh         # Create /var/lib/etcd
│   │   ├── distribute-etcd-certs.sh      # Push certs to etcd nodes
│   │   ├── gen-and-distribute-etcd-systemd-svc.sh
│   │   ├── start-etcd-servers.sh
│   │   ├── stop-etcd-servers.sh
│   │   └── test-etcd-connectivity.sh
│   │
│   ├── kube-apiserver/
│   │   ├── bootstrap-kube-apiservers.sh
│   │   ├── distribute-kube-apiserver-binary.sh
│   │   ├── distribute-master-certs.sh
│   │   ├── gen-admin-config.sh
│   │   ├── distribute-admin-config-and-kubectl.sh
│   │   ├── gen-encryption-config-and-distribute.sh
│   │   ├── gen-and-distribute-kube-apiserver-systemd-svc.sh
│   │   └── start-api-servers.sh
│   │
│   ├── kube-controller-manager/         # (same pattern)
│   ├── kube-scheduler/                  # (same pattern)
│   ├── kubelet/                         # (same pattern, 14 scripts)
│   ├── kube-proxy/                      # (same pattern, 8 scripts)
│   │
│   └── loadbalancer/
│       ├── haproxy.cfg                  # Reference config (manually generated)
│       └── haproxy/
│           ├── bootstrap-haproxy.sh
│           ├── install-haproxy.sh
│           ├── gen-and-copy-haproxy-cfg.sh
│           └── start-haproxy.sh
│
├── cluster-mgnt/cluster/
│   ├── roles/kube-apiserver-to-kubelet.yaml
│   ├── bindings/kube-apiserver-to-kubelet.yaml
│   └── sample-routes.conf               # Routes for pod CIDRs (if not using CNI)
│
├── deployments/
│   ├── nginx-with-ping-deployment.yaml   # 3-replica nginx for smoke test
│   └── nfs/
│       ├── pv-nfs.yaml                  # ReadWriteMany NFS PV
│       ├── pvc-nfs.yaml                 # Matching PVC
│       └── pod-busybox.yaml             # busybox writing to NFS mount
│
└── kube-binaries/                       # Built binaries (gitignored)
```

## Known limitations

- **No CoreDNS or DNS addon**: The kubelet config specifies `clusterDNS: 10.32.0.10` but no CoreDNS deployment or manifest is included. You must deploy CoreDNS (or any DNS provider) manually for service DNS resolution.
- **No kubeconfig for workers in repo**: Worker kubeconfigs are generated fresh each bootstrap in `kubeconfigs/worker-N.kubeconfig`. They are not committed.
- **kube-proxy not started automatically**: The bootstrap script for kube-proxy has its start step commented out. Run `scripts/kube-proxy/start-kube-proxies.sh` manually after bootstrap.
- **No dashboard or ingress**: The cluster is bare. Add them yourself via kubectl apply.
- **`certificate-template.txt` is a reference document**, not a script. Use the individual scripts in `certificates/scripts/`.
- **etcd version is pinned to v3.4.14** in `distribute-etcd-binary.sh`. The etcd release page has newer versions.
- **Service CIDR cannot overlap with LXD bridge subnet**. If your `lxdbr0` bridge assigns IPs in `10.32.0.0/24`, change `SERVICE_CLUSTER_IP_RANGE` in:
  - `scripts/kube-apiserver/gen-and-distribute-kube-apiserver-systemd-svc.sh`
  - `scripts/kube-controller-manager/gen-and-distribute-kube-controller-manager-systemd-svc.sh`
  - `scripts/kubelet/gen-and-distribute-kubelet-config-yaml.sh`

## License

This repository is documentation/scripting. Use freely. The Kubernetes source code built by this project is under the Apache 2.0 license.
