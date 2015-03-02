#!/bin/bash

sudo apt-get update
curl -sSL https://get.docker.com/ubuntu/ | sudo sh
source /etc/bash_completion.d/docker
usermod -a -G docker vagrant
