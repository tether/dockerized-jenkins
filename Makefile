CONTAINER_NAME := jenkins-server-container

install:
	./scripts/install.sh

clean:
	docker rm -v $$(docker ps -a -q | grep -v "$$(docker ps -q | xargs | sed 's/ /\\\|/g') ") 2>/dev/null || echo Nothing to do
	docker rmi $$(docker images --no-trunc | grep none | awk '{print $$3 }') 2>/dev/null || echo Nothing to do

build:
	./scripts/build.sh

start:
	docker run -d \
		--name $(CONTAINER_NAME) \
		-p 8080:8080 \
		-v /var/jenkins_home:/var/jenkins_home \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--restart always \
		jenkins_server

stop:
	@echo 'Stopping $(CONTAINER_NAME)'
	docker stop $(CONTAINER_NAME)

rebuild: build stop clean start

dev: build
	@mkdir -p .docker-dev/jenkins_home && sudo chown 1000:1000 .docker-dev/jenkins_home
	docker run -ti --rm \
		--name jenkins-server-dev \
		-p 8080:8080 \
		--volumes-from jenkins-server-dind \
		jenkins_server

dev.dind:
	docker run -d -ti \
		--privileged \
		--name jenkins-server-dind \
		-v `pwd`/.docker-dev/jenkins_home:/var/jenkins_home \
		-v `pwd`/.docker-dev/run:/var/run \
		fgrehm/alpine-dind
	@sleep 4
	sudo chown 0:999 .docker-dev/run/docker.sock
	sudo chmod +g .docker-dev/run/docker.sock

.PHONY: install clean build start stop rebuild dev dev.dind
