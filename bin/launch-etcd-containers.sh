#!/usr/bin/env bash

#Launch the etcd lxc containers

NUM_CONTAINERS=3
IMAGE=ubuntu:20.04
for ((n=1;n<=$NUM_CONTAINERS;n++))
do
  lxc launch $IMAGE etcd-$n
done
