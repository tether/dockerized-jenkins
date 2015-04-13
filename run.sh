#!/usr/bin/env bash

docker run --rm -p 8080:8080 -v /root/jenkins/myjenkins/data:/var/jenkins_home myjenkins
