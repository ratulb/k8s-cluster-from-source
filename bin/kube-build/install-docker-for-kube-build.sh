#!/usr/bin/env bash

echo "The user is : ${USER}"

if [ -x "$(command -v docker)" ]; then
    if [ "$(systemctl is-active docker)" = "inactive" ]; then
      echo "docker seems to be stopped. Trying to start docker"
      systemctl start docker
    fi
    if [ "$(systemctl is-active docker)" = "active" ]; then
          echo "Docker is running"
	  usermod -a -G docker ${USER}
    	  systemctl restart docker
    fi
else
    echo "Docker not installed. Installing docker...";
    cd /tmp
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh /tmp/get-docker.sh
    usermod -a -G docker ${USER}
    systemctl restart docker 
    cd -
fi


