#!/usr/bin/env bash

docker run --name jenkins-server-container -p 8080:8080 -v /var/jenkins_home:/var/jenkins_home --restart always -d jenkins_server
