#!/usr/bin/env bash
. ../run-as-root.sh

apt update 
apt install build-essential -y

DIST_DIR="../../kube-binaries/"
SRC_DIR="./kubernetes/"

mkdir -p ${DIST_DIR}

if [ ! -d "${SRC_DIR}" ]; then
 printf "Cloning kubernetes source repository...\n"
 git clone https://github.com/kubernetes/kubernetes.git --depth 1
else 
 cd ${SRC_DIR}
 printf "Pulling kubernetes latest sources...\n"
 git pull
 cd -
fi

#Install docker - without docker this process would not proceed

. install-docker.sh

cd ${SRC_DIR}

printf "\nInside source directory : ${SRC_DIR}\n"
if [ $# -eq 0 ]
  then
    printf "\nNo specific build target. Building all kube binaries.\n"
    build/run.sh make kubeadm KUBE_BUILD_PLATFORMS=linux/amd64
    build/run.sh make kubelet KUBE_BUILD_PLATFORMS=linux/amd64
    build/run.sh make kubectl KUBE_BUILD_PLATFORMS=linux/amd64
    build/run.sh make kube-controller-manager KUBE_BUILD_PLATFORMS=linux/amd64
    build/run.sh make kube-proxy KUBE_BUILD_PLATFORMS=linux/amd64
    build/run.sh make kube-scheduler KUBE_BUILD_PLATFORMS=linux/amd64
    build/run.sh make kube-apiserver KUBE_BUILD_PLATFORMS=linux/amd64
  else
    build_target=	  
    printf "\nBuild target is $1\n"
    build_target=$1

    case $build_target in

      kubeadm)
        printf "\nBuilding kubeadm\n"
        build/run.sh make kubeadm KUBE_BUILD_PLATFORMS=linux/amd64
      ;;

      kubelet)
        printf "\nBuilding kubelet\n"
        build/run.sh make kubelet KUBE_BUILD_PLATFORMS=linux/amd64
      ;;

      kubectl)
	printf "\nBuilding kubectl\n"
        build/run.sh make kubectl KUBE_BUILD_PLATFORMS=linux/amd64
      ;;
    
      kube-controller-manager)
        printf "\nBuilding kube-controller-manager\n"
        build/run.sh make kube-controller-manager KUBE_BUILD_PLATFORMS=linux/amd64
      ;;

      kube-proxy)
        printf "\nBuilding kube-proxy\n"
        build/run.sh make kube-proxy KUBE_BUILD_PLATFORMS=linux/amd64
      ;;
    
     kube-scheduler)
       printf  "\nBuilding kube-scheduler\n"
       build/run.sh make kube-scheduler KUBE_BUILD_PLATFORMS=linux/amd64
     ;;
    
     kube-apiserver)
       printf "\nBuilding kube-apiserver\n"
       build/run.sh make kube-apiserver KUBE_BUILD_PLATFORMS=linux/amd64
     ;;
  
     all | "-a" | "--all")
       printf "\nBuilding all kube binaries\n"
       
       build/run.sh make kubeadm KUBE_BUILD_PLATFORMS=linux/amd64
       build/run.sh make kubelet KUBE_BUILD_PLATFORMS=linux/amd64
       build/run.sh make kubectl KUBE_BUILD_PLATFORMS=linux/amd64
       build/run.sh make kube-controller-manager KUBE_BUILD_PLATFORMS=linux/amd64
       build/run.sh make kube-proxy KUBE_BUILD_PLATFORMS=linux/amd64
       build/run.sh make kube-scheduler KUBE_BUILD_PLATFORMS=linux/amd64
       build/run.sh make kube-apiserver KUBE_BUILD_PLATFORMS=linux/amd64
     ;;
  
     *)
       printf  "\nUnknown build target. Not building kube binaries.\n"
     ;;

  esac
fi

OUTPUT_DIR="${PWD}/_output/dockerized/bin/linux/amd64"
mv ${OUTPUT_DIR}/kube* ../${DIST_DIR}

ls -lh ../${DIST_DIR}
