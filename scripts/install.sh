#!/usr/bin/env bash
set -x

final_setup() {
  sudo bash -c 'echo "127.0.0.1 $(hostname)" 2>/dev/null >> /etc/hosts'
  sudo stop docker
  sudo bash -c 'echo DOCKER_OPTS=\" -g /opt/docker_images \" >> /etc/default/docker'
  sudo start docker
}

build_jenkins() {
  ./scripts/build.sh
}

message() {
  echo "################################################################################"
  echo "#                                                                              #"
  echo "#   Please run: $ source ~/.bashrc                                             #"
  echo "#   Add your jenkins data to /var/jenkins_home                                 #"
  echo "#   Start jenkins: $ make start                                                #"
  echo "#   Show jenkins image: $ docker images jenkins_server*                        #"
  echo "#                                                                              #"
  echo "################################################################################"
}

DOCKER_USER=`whoami` sudo -E ./scripts/install_docker.sh

final_setup
build_jenkins
message
