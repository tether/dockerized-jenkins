from jenkins


USER root

RUN apt-get install wget
RUN wget -qO- https://get.docker.com/ | sh


USER jenkins

ENV DOCKER_HOST=tcp://172.17.42.1:2375

COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

