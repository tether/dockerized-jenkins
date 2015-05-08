FROM jenkins:1.596.2

USER root

ADD . /usr/local/bin
RUN /usr/local/bin/install_docker.sh

USER jenkins

ENV DOCKER_HOST=tcp://172.17.42.1:2375

COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

ENV JAVA_OPTS "${JAVA_OPTS} -Dfile.encoding=UTF-8"
