#!/usr/bin/env bash
apt update 
apt install build-essential -y

DIST_DIR="../kube-binaries/"
SRC_DIR="./kubernetes/"

mkdir -p ${DIST_DIR}

if [ ! -d "${SRC_DIR}" ]; then
 echo "Cloning kubernetes source repository..."
 git clone https://github.com/kubernetes/kubernetes.git
else 
 cd ${SRC_DIR}
 echo "Pulling kubernetes latest sources..."
 git pull
 cd -
fi

#Install docker - without docker this process would not proceed

./install-docker-for-kube-build.sh

cd ${SRC_DIR}

echo "Inside source directory : ${SRC_DIR}"

#build/run.sh make kubeadm KUBE_BUILD_PLATFORMS=linux/amd64
#build/run.sh make kubelet KUBE_BUILD_PLATFORMS=linux/amd64
#build/run.sh make kube-proxy KUBE_BUILD_PLATFORMS=linux/amd64
build/run.sh make kubectl KUBE_BUILD_PLATFORMS=linux/amd64
#build/run.sh make kube-controller-manager KUBE_BUILD_PLATFORMS=linux/amd64
#build/run.sh make kube-proxy KUBE_BUILD_PLATFORMS=linux/amd64
#build/run.sh make kube-scheduler KUBE_BUILD_PLATFORMS=linux/amd64
#build/run.sh make kube-apiserver KUBE_BUILD_PLATFORMS=linux/amd64
#Copy build artifects from output directory to distribution location

OUTPUT_DIR="${PWD}/_output/dockerized/bin/linux/amd64"
mv ${OUTPUT_DIR}/kube* ../${DIST_DIR}

ls -lh ../${DIST_DIR}
