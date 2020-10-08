# kubernetes-cluster-ground-up-from-source
Set up a kubernetes cluster from latest sources in lxd containers step by step.

This repository is for those who really want to get their hands dirty with kubernetes. It sets up a k8s cluster ground up from latest kubernetes github source codes - it pulls down the latest code - generates the kube binaries (kubeadm is also built but - we set up the cluster without using kubeadm). 

We use lxd containers(https://linuxcontainers.org/lxd/) for setting up the cluster in ubuntu linux(20.04/18.04). Since ubuntu comes pre-loaded with lxd/lxc - setting up the virtual boxes become a breeze.

This provides a very flexible way to experiment with not only the kubernetes framework but also the applications and functionalities that can be built on top of kubernetes.


