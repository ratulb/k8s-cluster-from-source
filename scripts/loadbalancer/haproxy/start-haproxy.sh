#!/usr/bin/env bash
. ../../run-as-root.sh
#Allow binding at port 80

echo 'net.ipv4.ip_nonlocal_bind=1' >> /etc/sysctl.conf
lxc exec loadbalancer -- sysctl -p
lxc exec loadbalancer -- systemctl daemon-reload
lxc exec loadbalancer -- systemctl stop haproxy
lxc exec loadbalancer -- systemctl enable haproxy
lxc exec loadbalancer -- systemctl start haproxy

