#!/usr/bin/env bash

echo "Running as: ${USER}"
if ! [ $(id -u) = 0 ]; then
   echo "This needs to be run as root!!!"
   exit 1
fi
