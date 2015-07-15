#!/usr/bin/env bash

install_dependencies() {
  apt-get update
  apt-get install -y wget bash curl make
}

install_docker() {
  wget -qO- https://get.docker.com/ | sh
  usermod -aG docker `whoami`
}

install_docker_compose() {
  curl -L https://github.com/docker/compose/releases/download/1.3.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
}

install_dependencies
install_docker
install_docker_compose
