#!/usr/bin/env bash
set -e

source ~/.bashrc

echo 'Building jenkins server image'
docker build -t jenkins_server jenkins_server
