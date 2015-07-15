FROM jenkins:1.596.2
# https://github.com/cloudbees/jenkins-ci.org-docker/blob/master/Dockerfile

USER root

COPY jenkins/bin /usr/local/bin

COPY scripts/install_docker.sh /tmp/install_docker.sh
RUN /tmp/install_docker.sh

USER jenkins

ENV DOCKER_HOST=tcp://172.17.42.1:2375

COPY jenkins/plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

ENV JAVA_OPTS "${JAVA_OPTS} -Dfile.encoding=UTF-8"
