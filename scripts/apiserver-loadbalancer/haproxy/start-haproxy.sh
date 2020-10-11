#!/usr/bin/env bash
. ../../run-as-root.sh
lxc exec loadbalancer -- systemctl daemon-reload
lxc exec loadbalancer -- systemctl stop haproxy
lxc exec loadbalancer -- systemctl enable haproxy
lxc exec loadbalancer -- systemctl start haproxy

