# AGENTS.md — k8s-cluster-from-source

## What this repo does
Builds Kubernetes from the latest GitHub source (`git clone --depth 1`) and deploys it on LXD containers without kubeadm. Targets Ubuntu 18.04/20.04.

## Staleness notice
This project was unmaintained for a while. Expect bitrot across the board:
- **Kubernetes build**: `build/run.sh make` was removed upstream. Building from source now requires `make` directly or `kube::build::` helpers. The build script at `scripts/kube-build/build-binaries.sh` will likely fail as-is.
- **LXD and LXC**: The `lxc` CLI, kernel module names, and container defaults may have changed. The raw LXC config in `lxd/lxd-config-kubelet-boxes.sh` may need updating.
- **etcd version**: Pinned to `v3.4.14` in `scripts/etcd/distribute-etcd-binary.sh`. Modern clusters should use v3.5+.
- **containerd / runc**: Pinned to `cri-containerd-cni-1.3.4`. Current releases are 1.7+; the archive URL and config format have changed.
- **Kubernetes API versions**: Config files in `systemd/` and `deployments/` use old API versions (e.g. `kubescheduler.config.k8s.io/v1beta1`, `kubeproxy.config.k8s.io/v1alpha1`). These must be bumped.
- **CNI bridge config**: The bridge plugin JSON format may have drifted.
- **`kube-proxy` bootstrap**: The start step (`start-kube-proxies.sh`) is commented out in `bootstrap-kube-proxies.sh`. Intentionally left as an exercise but worth noting.

Every script should be reviewed and updated before attempting a fresh deployment.

## Infrastructure topology
- 3 etcd nodes: `etcd-1` `etcd-2` `etcd-3`
- 3 control-plane nodes: `master-1` `master-2` `master-3`
- 3 worker nodes: `worker-1` `worker-2` `worker-3`
- 1 loadbalancer: `loadbalancer` (HAProxy fronting port 6443)

## Build (scripts/kube-build/)
`./build-binaries.sh` — clones k8s source, runs `build/run.sh make <target> KUBE_BUILD_PLATFORMS=linux/amd64`, moves binaries to `kube-binaries/`. Pass a single target name (e.g. `kubelet`) or `all`/`-a`/`--all`. Requires Docker (auto-installed by `install-docker.sh`). Must be run as root.

## Bootstrap order
Each component bootstrap script sources sub-steps via `.` (not subprocess). Follow this order:

1. `certificates/scripts/install-cfssl-cfssljson.sh`
2. `certificates/scripts/gen-*.sh` (CA first, then individual certs)
3. `scripts/etcd/bootstrap-etcd-servers.sh`
4. `scripts/kube-apiserver/bootstrap-kube-apiservers.sh`
5. `scripts/kube-controller-manager/bootstrap-kube-controller-managers.sh`
6. `scripts/kube-scheduler/bootstrap-kube-schedulers.sh`
7. `scripts/loadbalancer/haproxy/bootstrap-haproxy.sh`
8. `scripts/kubelet/bootstrap-kubelets.sh`
9. `scripts/kube-proxy/bootstrap-kube-proxies.sh`

## Cluster start/stop
- `scripts/start-cluster.sh` — workers → masters → etcd → loadbalancer
- `scripts/shutdown-cluster.sh` — reverse order (stops same sequence)

Both use `lxc exec <instance> -- systemctl <start|stop> <service>`. Must be run as root.

## Key paths
| Path | Notes |
|------|-------|
| `kube-binaries/` | Built binaries output (gitignored) |
| `certificates/generated/` | Generated certs (gitignored) |
| `scripts/kube-build/kubernetes/` | Cloned k8s source (gitignored) |
| `kubeconfigs/` | Pre-generated kubeconfigs (admin, controller-manager, proxy, scheduler) |
| `systemd/` | Systemd unit files per component (etcd, kube-*) |
| `deployments/` | Sample manifests (nginx deployment, NFS PV/PVC/pod) |
| `encryption/encryption-config.yaml` | AES-CBC encryption config for secrets |
| `lxd/` | LXD profile + container kernel config |

## Certificate generation
Uses CFSSL. Template at `certificates/certificate-template.txt`. Individual scripts in `certificates/scripts/gen-*.sh`. The API server SAN includes loadbalancer IP + all master IPs + `127.0.0.1` + kubernetes service hostnames.

## Gitignore note
`*.csr`, `*.pem`, `*.json`, `*.bak` are ignored. Generated JSON configs (e.g., kube-scheduler config yaml) may not be tracked.

## Sample deployments
- `deployments/nginx-with-ping-deployment.yaml` — 3-replica nginx deployment
- `deployments/nfs/` — NFS-based PV (ReadWriteMany), PVC, busybox pod writing to NFS
- `cluster-mgnt/cluster/roles/` and `bindings/` — ClusterRole/ClusterRoleBinding for apiserver→kubelet
