#!/usr/bin/env bash
set -e

source ~/.bashrc

docker build -t jenkins_server jenkins_server
