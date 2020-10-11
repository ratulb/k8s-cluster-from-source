#!/usr/bin/env bash
. ../../run-as-root.sh

lxc exec loadbalancer -- apt-get update
lxc exec loadbalancer -- apt-get install -y haproxy



