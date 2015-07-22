#!/usr/bin/env bash
set -e

echo 'Building jenkins server image'
docker build -t jenkins_server .
