#!/usr/bin/env bash
. ../run-as-root.sh
WORKERS=
if [ $# -eq 0 ];
  then
    WORKERS="worker-1 worker-2 worker-3"
  else
    WORKERS=$@
fi
echo "Setting up for $WORKERS"
for instance in $WORKERS; do
 lxc exec ${instance} -- apt-get update
 lxc exec ${instance} -- apt-get install -y libseccomp2 socat conntrack ipset
echo "Setting up os dependencies in $instance"
done
printf "Done installing os dependencies..."
