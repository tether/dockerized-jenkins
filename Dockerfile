FROM jenkins:1.596.2
# https://github.com/cloudbees/jenkins-ci.org-docker/blob/master/Dockerfile

COPY scripts/install_docker.sh /tmp
RUN DOCKER_USER=jenkins sudo -E /tmp/install_docker.sh

COPY jenkins/bin /usr/local/bin
COPY jenkins/plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

ENV DOCKER_HOST=/tmp/docker.sock
ENV JAVA_OPTS "${JAVA_OPTS} -Dfile.encoding=UTF-8"
