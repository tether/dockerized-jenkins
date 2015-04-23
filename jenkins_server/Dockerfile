FROM jenkins:1.596.2

USER root

RUN apt-get install wget
RUN wget -qO- https://get.docker.com/ | sh

ADD run.on.docker /usr/local/bin/run.on.docker

USER jenkins

ENV DOCKER_HOST=tcp://172.17.42.1:2375

COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

ENV JAVA_OPTS "${JAVA_OPTS} -Dfile.encoding=UTF-8"
