#!/usr/bin/env bash
set -x

DOCKER_EXPORT='export DOCKER_HOST=tcp://172.17.42.1:2375'

install_dependencies() {
  sudo apt-get update
  sudo apt-get install -y wget bash curl make
}

install_docker() {
  wget -qO- https://get.docker.com/ | sudo sh
  sudo usermod -aG docker `whoami`
}

final_setup() {
  sudo bash -c 'echo "127.0.0.1 $(hostname)" 2>/dev/null >> /etc/hosts'
  sudo stop docker
  sudo bash -c 'echo DOCKER_OPTS=\"-H 0.0.0.0:2375\" >> /etc/default/docker'
  echo $DOCKER_EXPORT >> $HOME/.bashrc
  sudo start docker

  mkdir /var/jenkins_home  
  chown -R ubuntu:ubuntu /var/jenkins_home
}

build_jenkins() {
  ./build.sh
}

message() {
  set +x
  echo "################################################################################"
  echo "#                                                                              #"
  echo "#   Please run: $ source ~/.bashrc                                             #"
  echo "#   Add your jenkins data to /var/jenkins_home                                 #"
  echo "#   Start jenkins: $ make start                                                #"
  echo "#   Show jenkins image: $ docker images | grep jenkins_server                  #"
  echo "#                                                                              #"
  echo "################################################################################"
}

install_dependencies
install_docker
final_setup
build_jenkins
message
